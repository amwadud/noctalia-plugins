import QtQuick
import Quickshell.Io
import qs.Services.UI
import qs.Commons

Item {
    id: root

    property var pluginApi: null

    // ── State ─────────────────────────────────────────────────────────────────
    property var alarms: pluginApi?.pluginSettings?.alarms ?? []
    property string ringingAlarmId: ""
    property bool isRinging: ringingAlarmId !== ""
    property string nextAlarmTime: ""
    property string nextAlarmLabel: ""

    // ── Helpers ───────────────────────────────────────────────────────────────
    function pad(n) {
        return n < 10 ? "0" + n : "" + n
    }

    function formatTime(h, m) {
        return pad(h) + ":" + pad(m)
    }

    function updateNextAlarm() {
        var now = new Date()
        var nowMins = now.getHours() * 60 + now.getMinutes()
        var best = -1
        var bestLabel = ""
        var bestTime = ""
        var list = root.alarms
        for (var i = 0; i < list.length; i++) {
            var a = list[i]
            if (!a.enabled) continue
            var am = a.hour * 60 + a.minute
            var diff = am - nowMins
            if (diff < 0) diff += 1440
            if (best < 0 || diff < best) {
                best = diff
                bestLabel = a.label
                bestTime = formatTime(a.hour, a.minute)
            }
        }
        root.nextAlarmLabel = bestLabel
        root.nextAlarmTime = bestTime
    }

    function checkAlarms() {
        if (root.isRinging) return
        var h = new Date().getHours()
        var m = new Date().getMinutes()
        var list = JSON.parse(JSON.stringify(root.alarms))
        var changed = false
        for (var i = 0; i < list.length; i++) {
            var a = list[i]
            if (!a.enabled) continue
            if (a.hour !== h || a.minute !== m) continue
            root.ringingAlarmId = a.id
            if (pluginApi?.pluginSettings?.notificationEnabled !== false) {
                ToastService.showNotice("⏰ " + a.label + " — " + formatTime(h, m))
            }
            if (!a.repeat) {
                list[i].enabled = false
                changed = true
            }
            break
        }
        if (changed) {
            pluginApi.pluginSettings.alarms = list
            pluginApi.saveSettings()
            root.alarms = list
        }
    }

    function addAlarm(label, hour, minute, repeat) {
        var list = JSON.parse(JSON.stringify(root.alarms))
        list.push({
            id: "alarm_" + Date.now(),
            label: label || "Alarm",
            hour: parseInt(hour),
            minute: parseInt(minute),
            enabled: true,
            repeat: repeat || false
        })
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
        ToastService.showNotice("Alarm set for " + formatTime(parseInt(hour), parseInt(minute)))
    }

    function removeAlarm(id) {
        var list = root.alarms.filter(function(a) { return a.id !== id })
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
    }

    function toggleAlarm(id) {
        var list = JSON.parse(JSON.stringify(root.alarms))
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) { list[i].enabled = !list[i].enabled; break }
        }
        pluginApi.pluginSettings.alarms = list
        pluginApi.saveSettings()
        root.alarms = list
        root.updateNextAlarm()
    }

    function dismissAlarm() {
        root.ringingAlarmId = ""
        root.updateNextAlarm()
    }

    function snoozeAlarm() {
        if (!root.isRinging) return
        var mins = pluginApi?.pluginSettings?.snoozeMinutes ?? 5
        snoozeTimer.interval = mins * 60 * 1000
        snoozeTimer.savedId = root.ringingAlarmId
        snoozeTimer.restart()
        root.ringingAlarmId = ""
        ToastService.showNotice("Snoozed for " + mins + " minutes")
    }

    // ── Timers ────────────────────────────────────────────────────────────────
    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            root.checkAlarms()
            root.updateNextAlarm()
        }
    }

    Timer {
        id: snoozeTimer
        property string savedId: ""
        repeat: false
        onTriggered: {
            if (savedId !== "") {
                root.ringingAlarmId = savedId
                savedId = ""
                if (pluginApi?.pluginSettings?.notificationEnabled !== false) {
                    ToastService.showNotice("⏰ Snooze over!")
                }
            }
        }
    }

    Component.onCompleted: {
        root.updateNextAlarm()
    }

    // ── IPC ───────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "plugin:alarm-clock"

        function toggle() {
            pluginApi.withCurrentScreen(function(screen) {
                pluginApi.openPanel(screen)
            })
        }

        function dismiss() {
            root.dismissAlarm()
        }

        function snooze() {
            root.snoozeAlarm()
        }

        function add(label: string, hour: string, minute: string) {
            root.addAlarm(label, parseInt(hour), parseInt(minute), false)
        }
    }
}
