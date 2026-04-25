import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // ── State ────────────────────────────────────────────────────────────────

    // Alarms list: [{id, label, hour, minute, enabled, repeat, days:[0-6], snoozed}]
    property var alarms: pluginApi?.pluginSettings?.alarms ?? []

    // Currently ringing alarm id (empty string = none)
    property string ringingAlarmId: ""
    property bool isRinging: ringingAlarmId !== ""

    // Next upcoming alarm display (for bar widget)
    property string nextAlarmLabel: ""
    property string nextAlarmTime: ""
    property bool hasUpcomingAlarm: nextAlarmTime !== ""

    // ── Clock tick (every 30s is enough; we check :00 seconds window) ────────
    Timer {
        id: clockTimer
        interval: 10000   // check every 10 seconds
        repeat: true
        running: true
        onTriggered: {
            root.checkAlarms()
            root.updateNextAlarm()
        }
    }

    // Initial update
    Component.onCompleted: {
        root.updateNextAlarm()
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    function padTwo(n) {
        return n < 10 ? "0" + n : "" + n
    }

    function formatTime(hour, minute) {
        return padTwo(hour) + ":" + padTwo(minute)
    }

    function nowHour() {
        return new Date().getHours()
    }

    function nowMinute() {
        return new Date().getMinutes()
    }

    function nowDay() {
        // 0=Sun,1=Mon,...,6=Sat  (same as JS Date)
        return new Date().getDay()
    }

    function alarmShouldRingNow(alarm) {
        if (!alarm.enabled) return false
        if (alarm.snoozed) return false
        var h = nowHour()
        var m = nowMinute()
        if (alarm.hour !== h || alarm.minute !== m) return false
        // repeat: check day
        if (alarm.repeat && alarm.days && alarm.days.length > 0) {
            return alarm.days.indexOf(nowDay()) >= 0
        }
        return true
    }

    function checkAlarms() {
        var updated = false
        var alarmsCopy = JSON.parse(JSON.stringify(root.alarms))
        for (var i = 0; i < alarmsCopy.length; i++) {
            var a = alarmsCopy[i]
            if (alarmShouldRingNow(a) && root.ringingAlarmId === "") {
                root.ringingAlarmId = a.id
                sendNotification(a)
                Logger.i("AlarmClock", "Alarm triggered: " + a.label)
                // If not repeating, disable after ring
                if (!a.repeat) {
                    alarmsCopy[i].enabled = false
                    updated = true
                }
            }
        }
        if (updated) {
            pluginApi.pluginSettings.alarms = alarmsCopy
            pluginApi.saveSettings()
        }
    }

    function sendNotification(alarm) {
        if (pluginApi?.pluginSettings?.notificationEnabled !== false) {
            ToastService.showNotice("⏰ Alarm: " + alarm.label + " — " + formatTime(alarm.hour, alarm.minute))
        }
    }

    function updateNextAlarm() {
        var now = new Date()
        var nowMinutes = now.getHours() * 60 + now.getMinutes()
        var earliest = -1
        var earliestLabel = ""
        var earliestTime = ""

        var list = root.alarms
        for (var i = 0; i < list.length; i++) {
            var a = list[i]
            if (!a.enabled) continue
            var alarmMinutes = a.hour * 60 + a.minute
            var diff = alarmMinutes - nowMinutes
            if (diff < 0) diff += 1440  // next day
            if (earliest < 0 || diff < earliest) {
                earliest = diff
                earliestLabel = a.label
                earliestTime = formatTime(a.hour, a.minute)
            }
        }

        root.nextAlarmLabel = earliestLabel
        root.nextAlarmTime = earliestTime
    }

    function addAlarm(label, hour, minute, repeat, days) {
        var list = JSON.parse(JSON.stringify(root.alarms))
        var id = "alarm_" + Date.now()
        list.push({
            id: id,
            label: label || "Alarm",
            hour: hour,
            minute: minute,
            enabled: true,
            repeat: repeat || false,
            days: days || [],
            snoozed: false
        })
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
        ToastService.showNotice("Alarm set for " + formatTime(hour, minute))
        Logger.i("AlarmClock", "Alarm added: " + label + " at " + formatTime(hour, minute))
    }

    function removeAlarm(id) {
        var list = JSON.parse(JSON.stringify(root.alarms))
        list = list.filter(function(a) { return a.id !== id })
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
    }

    function toggleAlarm(id) {
        var list = JSON.parse(JSON.stringify(root.alarms))
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list[i].enabled = !list[i].enabled
                break
            }
        }
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
    }

    function dismissAlarm() {
        root.ringingAlarmId = ""
    }

    function snoozeAlarm() {
        if (root.ringingAlarmId === "") return
        var list = JSON.parse(JSON.stringify(root.alarms))
        var snoozeMin = pluginApi?.pluginSettings?.snoozeMinutes ?? 5
        var snoozeMs = snoozeMin * 60 * 1000
        // Schedule a one-shot snooze re-ring
        snoozeTimer.snoozeAlarmId = root.ringingAlarmId
        snoozeTimer.interval = snoozeMs
        snoozeTimer.restart()
        root.ringingAlarmId = ""
        ToastService.showNotice("Snoozed for " + snoozeMin + " minutes")
    }

    // ── Snooze one-shot timer ─────────────────────────────────────────────────
    Timer {
        id: snoozeTimer
        property string snoozeAlarmId: ""
        repeat: false
        onTriggered: {
            if (snoozeAlarmId !== "") {
                root.ringingAlarmId = snoozeAlarmId
                // Find the alarm and notify
                var list = root.alarms
                for (var i = 0; i < list.length; i++) {
                    if (list[i].id === snoozeAlarmId) {
                        root.sendNotification(list[i])
                        break
                    }
                }
                snoozeAlarmId = ""
            }
        }
    }

    // ── Watch settings changes ────────────────────────────────────────────────
    Connections {
        target: pluginApi
        function onPluginSettingsChanged() {
            root.alarms = pluginApi.pluginSettings.alarms ?? []
            root.updateNextAlarm()
        }
    }

    // ── IPC Handler ──────────────────────────────────────────────────────────
    IpcHandler {
        target: "plugin:alarm-clock"

        // qs -c noctalia-shell ipc call plugin:alarm-clock toggle
        function toggle() {
            pluginApi.togglePanel(pluginApi.panelOpenScreen ?? null)
        }

        // qs -c noctalia-shell ipc call plugin:alarm-clock dismiss
        function dismiss() {
            root.dismissAlarm()
        }

        // qs -c noctalia-shell ipc call plugin:alarm-clock snooze
        function snooze() {
            root.snoozeAlarm()
        }

        // qs -c noctalia-shell ipc call plugin:alarm-clock add "Wake up" 7 30
        function add(label, hour, minute) {
            root.addAlarm(label, parseInt(hour), parseInt(minute), false, [])
        }
    }
}
