import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // Per-screen bar properties
    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    // Alias into Main.qml state
    readonly property var main: pluginApi?.mainInstance
    readonly property bool isRinging: main?.isRinging ?? false
    readonly property string nextAlarmTime: main?.nextAlarmTime ?? ""
    readonly property bool hasUpcomingAlarm: nextAlarmTime !== ""

    readonly property real contentWidth: row.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // ── Ringing pulse animation ───────────────────────────────────────────────
    SequentialAnimation {
        id: ringPulse
        running: root.isRinging
        loops: Animation.Infinite

        PropertyAnimation {
            target: visualCapsule
            property: "opacity"
            to: 0.4
            duration: 400
            easing.type: Easing.InOutSine
        }
        PropertyAnimation {
            target: visualCapsule
            property: "opacity"
            to: 1.0
            duration: 400
            easing.type: Easing.InOutSine
        }
    }

    onIsRingingChanged: {
        if (!isRinging) {
            visualCapsule.opacity = 1.0
        }
    }

    Rectangle {
        id: visualCapsule

        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight

        color: root.isRinging
            ? Color.mPrimary
            : (mouseArea.containsMouse ? Color.mHover : Style.capsuleColor)
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Style.marginS

            NIcon {
                id: bellIcon
                icon: root.isRinging ? "bell-ringing" : (root.hasUpcomingAlarm ? "bell" : "bell-off")
                color: root.isRinging ? Color.mOnPrimary : Color.mOnSurface
                pointSize: root.barFontSize
                transformOrigin: Item.Bottom

                SequentialAnimation on rotation {
                    running: root.isRinging
                    loops: Animation.Infinite
                    NumberAnimation { to: -12; duration: 120; easing.type: Easing.InOutSine }
                    NumberAnimation { to:  12; duration: 120; easing.type: Easing.InOutSine }
                    NumberAnimation { to:  -8; duration: 100; easing.type: Easing.InOutSine }
                    NumberAnimation { to:   8; duration: 100; easing.type: Easing.InOutSine }
                    NumberAnimation { to:   0; duration: 80;  easing.type: Easing.InOutSine }
                    PauseAnimation  { duration: 600 }
                }

                onIsRingingChanged: {
                    if (!root.isRinging) rotation = 0
                }
            }

            NText {
                visible: root.isRinging || root.hasUpcomingAlarm
                text: root.isRinging ? "Ringing!" : root.nextAlarmTime
                color: root.isRinging ? Color.mOnPrimary : Color.mOnSurface
                pointSize: root.barFontSize
                font.weight: root.isRinging ? Font.Bold : Font.Normal
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (pluginApi) {
                pluginApi.openPanel(root.screen, root)
            }
        }

        onEntered: {
            var tip = root.isRinging
                ? "Alarm ringing! Click to manage"
                : (root.hasUpcomingAlarm
                    ? "Next alarm: " + (main?.nextAlarmLabel ?? "") + " at " + root.nextAlarmTime
                    : "No alarms set")
            TooltipService.show(root, tip, BarService.getTooltipDirection())
        }
        onExited: TooltipService.hide()
    }
}
