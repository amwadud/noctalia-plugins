import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // Per-screen bar properties (official pattern)
    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    // Aliases into Main
    readonly property var main: pluginApi?.mainInstance
    readonly property bool isRinging: main?.isRinging ?? false
    readonly property string nextAlarmTime: main?.nextAlarmTime ?? ""
    readonly property string nextAlarmLabel: main?.nextAlarmLabel ?? ""
    readonly property bool hasAlarm: nextAlarmTime !== ""

    readonly property real contentWidth: row.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // Visual capsule (official pattern: centered Rectangle inside Item)
    Rectangle {
        id: visualCapsule

        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight

        // Hover via binding (official recommended pattern — no onEntered/onExited)
        color: root.isRinging ? Color.mPrimary : (mouseArea.containsMouse ? Color.mHover : Style.capsuleColor)
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Pulse opacity when ringing
        SequentialAnimation {
            running: root.isRinging
            loops: Animation.Infinite
            PropertyAnimation { target: visualCapsule; property: "opacity"; to: 0.55; duration: 500; easing.type: Easing.InOutSine }
            PropertyAnimation { target: visualCapsule; property: "opacity"; to: 1.0;  duration: 500; easing.type: Easing.InOutSine }
        }

        onVisibleChanged: { if (!root.isRinging) opacity = 1.0 }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Style.marginS

            NIcon {
                icon: root.isRinging ? "bell-ringing" : (root.hasAlarm ? "bell" : "bell-off")
                color: root.isRinging ? Color.mOnPrimary : Color.mOnSurface
                pointSize: root.barFontSize
            }

            NText {
                visible: root.isRinging || root.hasAlarm
                text: root.isRinging ? "Ringing!" : root.nextAlarmTime
                color: root.isRinging ? Color.mOnPrimary : Color.mOnSurface
                pointSize: root.barFontSize
                font.weight: root.isRinging ? Font.Bold : Font.Normal
            }
        }
    }

    // MouseArea at root level (official pattern)
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
                : (root.hasAlarm ? "Next: " + root.nextAlarmLabel + " at " + root.nextAlarmTime : "No alarms set")
            TooltipService.show(root, tip, BarService.getTooltipDirection())
        }
        onExited: TooltipService.hide()
    }
}
