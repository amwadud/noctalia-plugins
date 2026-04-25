import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 420 * Style.uiScaleRatio
    property real contentPreferredHeight: 560 * Style.uiScaleRatio

    anchors.fill: parent

    // ── Aliases into Main ─────────────────────────────────────────────────────
    readonly property var main: pluginApi?.mainInstance
    readonly property bool isRinging: main?.isRinging ?? false
    readonly property var alarms: main?.alarms ?? []

    // ── Add-alarm form state ──────────────────────────────────────────────────
    property bool showAddForm: false
    property int newHour: 7
    property int newMinute: 0
    property string newLabel: ""
    property bool newRepeat: false
    property var newDays: []   // [0..6]

    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    // ── Root panel container ──────────────────────────────────────────────────
    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginL
            }
            spacing: Style.marginM

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                NIcon {
                    icon: "bell"
                    color: Color.mPrimary
                    pointSize: Style.fontSizeL
                }

                NText {
                    text: "Alarm Clock"
                    pointSize: Style.fontSizeL
                    font.weight: Font.Bold
                    color: Color.mOnSurface
                    Layout.fillWidth: true
                    leftPadding: Style.marginS
                }

                NIconButton {
                    icon: "plus"
                    onClicked: root.showAddForm = !root.showAddForm
                }
            }

            // ── Ringing Banner ────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 80 * Style.uiScaleRatio
                visible: root.isRinging
                color: Color.mPrimary
                radius: Style.radiusL

                SequentialAnimation on opacity {
                    running: root.isRinging
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.75; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 500; easing.type: Easing.InOutSine }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        margins: Style.marginM
                    }
                    spacing: Style.marginM

                    NIcon {
                        icon: "bell-ringing"
                        color: Color.mOnPrimary
                        pointSize: Style.fontSizeXL

                        SequentialAnimation on rotation {
                            running: root.isRinging
                            loops: Animation.Infinite
                            NumberAnimation { to: -12; duration: 120 }
                            NumberAnimation { to:  12; duration: 120 }
                            NumberAnimation { to:  -8; duration: 100 }
                            NumberAnimation { to:   8; duration: 100 }
                            NumberAnimation { to:   0; duration: 80  }
                            PauseAnimation  { duration: 500 }
                        }
                    }

                    NText {
                        text: "Alarm ringing!"
                        color: Color.mOnPrimary
                        pointSize: Style.fontSizeM
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        spacing: Style.marginXS

                        NButton {
                            text: "Dismiss"
                            Layout.fillWidth: true
                            onClicked: main?.dismissAlarm()
                        }

                        NButton {
                            text: "Snooze " + (pluginApi?.pluginSettings?.snoozeMinutes ?? 5) + "m"
                            Layout.fillWidth: true
                            onClicked: main?.snoozeAlarm()
                        }
                    }
                }
            }

            // ── Add Alarm Form ────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                visible: root.showAddForm
                height: addFormLayout.implicitHeight + Style.marginL * 2
                color: Color.mSurfaceVariant
                radius: Style.radiusL

                ColumnLayout {
                    id: addFormLayout
                    anchors {
                        fill: parent
                        margins: Style.marginL
                    }
                    spacing: Style.marginM

                    NText {
                        text: "New Alarm"
                        pointSize: Style.fontSizeM
                        font.weight: Font.Bold
                        color: Color.mOnSurface
                    }

                    // Label input
                    NTextInput {
                        id: labelInput
                        Layout.fillWidth: true
                        label: "Label"
                        placeholderText: "Wake up"
                        text: root.newLabel
                        onTextChanged: root.newLabel = text
                    }

                    // Time picker row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        NText {
                            text: "Time:"
                            color: Color.mOnSurfaceVariant
                        }

                        // Hour spinner
                        Rectangle {
                            width: 60 * Style.uiScaleRatio
                            height: 36 * Style.uiScaleRatio
                            color: Color.mSurface
                            radius: Style.radiusM
                            border.color: Style.capsuleBorderColor
                            border.width: Style.capsuleBorderWidth

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                NIconButton {
                                    icon: "chevron-up"
                                    Layout.fillHeight: true
                                    onClicked: root.newHour = (root.newHour + 1) % 24
                                }

                                NText {
                                    text: main?.padTwo(root.newHour) ?? "07"
                                    color: Color.mOnSurface
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                NIconButton {
                                    icon: "chevron-down"
                                    Layout.fillHeight: true
                                    onClicked: root.newHour = (root.newHour + 23) % 24
                                }
                            }
                        }

                        NText {
                            text: ":"
                            color: Color.mOnSurface
                            font.weight: Font.Bold
                            pointSize: Style.fontSizeL
                        }

                        // Minute spinner
                        Rectangle {
                            width: 60 * Style.uiScaleRatio
                            height: 36 * Style.uiScaleRatio
                            color: Color.mSurface
                            radius: Style.radiusM
                            border.color: Style.capsuleBorderColor
                            border.width: Style.capsuleBorderWidth

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                NIconButton {
                                    icon: "chevron-up"
                                    Layout.fillHeight: true
                                    onClicked: root.newMinute = (root.newMinute + 1) % 60
                                }

                                NText {
                                    text: main?.padTwo(root.newMinute) ?? "00"
                                    color: Color.mOnSurface
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                NIconButton {
                                    icon: "chevron-down"
                                    Layout.fillHeight: true
                                    onClicked: root.newMinute = (root.newMinute + 59) % 60
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Repeat toggle
                    RowLayout {
                        Layout.fillWidth: true

                        NText {
                            text: "Repeat"
                            color: Color.mOnSurfaceVariant
                            Layout.fillWidth: true
                        }

                        NToggle {
                            checked: root.newRepeat
                            onCheckedChanged: root.newRepeat = checked
                        }
                    }

                    // Day selector (visible only when repeat is on)
                    Flow {
                        Layout.fillWidth: true
                        visible: root.newRepeat
                        spacing: Style.marginXS

                        Repeater {
                            model: root.dayNames

                            Rectangle {
                                width: 38 * Style.uiScaleRatio
                                height: 28 * Style.uiScaleRatio
                                radius: Style.radiusM
                                color: root.newDays.indexOf(index) >= 0
                                    ? Color.mPrimary
                                    : Color.mSurface
                                border.color: Style.capsuleBorderColor
                                border.width: Style.capsuleBorderWidth

                                NText {
                                    anchors.centerIn: parent
                                    text: modelData
                                    pointSize: Style.fontSizeXS
                                    color: root.newDays.indexOf(index) >= 0
                                        ? Color.mOnPrimary
                                        : Color.mOnSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var d = root.newDays.slice()
                                        var pos = d.indexOf(index)
                                        if (pos >= 0) d.splice(pos, 1)
                                        else d.push(index)
                                        root.newDays = d
                                    }
                                }
                            }
                        }
                    }

                    // Action buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        NButton {
                            text: "Cancel"
                            Layout.fillWidth: true
                            onClicked: {
                                root.showAddForm = false
                                root.newLabel = ""
                                root.newHour = 7
                                root.newMinute = 0
                                root.newRepeat = false
                                root.newDays = []
                                labelInput.text = ""
                            }
                        }

                        NButton {
                            text: "Add Alarm"
                            Layout.fillWidth: true
                            onClicked: {
                                main?.addAlarm(
                                    root.newLabel || "Alarm",
                                    root.newHour,
                                    root.newMinute,
                                    root.newRepeat,
                                    root.newDays
                                )
                                root.showAddForm = false
                                root.newLabel = ""
                                root.newHour = 7
                                root.newMinute = 0
                                root.newRepeat = false
                                root.newDays = []
                                labelInput.text = ""
                            }
                        }
                    }
                }
            }

            // ── Alarm List ────────────────────────────────────────────────────
            NScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: Style.marginS

                    // Empty state
                    Item {
                        Layout.fillWidth: true
                        height: 120 * Style.uiScaleRatio
                        visible: root.alarms.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS

                            NIcon {
                                icon: "bell-off"
                                color: Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeXXL
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.5
                            }

                            NText {
                                text: "No alarms set"
                                color: Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeS
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.7
                            }

                            NText {
                                text: "Tap + to add one"
                                color: Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeXS
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.5
                            }
                        }
                    }

                    // Alarm rows
                    Repeater {
                        model: root.alarms

                        Rectangle {
                            width: parent.width
                            height: alarmRow.implicitHeight + Style.marginM * 2
                            radius: Style.radiusL
                            color: modelData.enabled
                                ? Color.mSurfaceVariant
                                : Color.mSurface
                            border.color: (main?.ringingAlarmId === modelData.id)
                                ? Color.mPrimary
                                : Style.capsuleBorderColor
                            border.width: (main?.ringingAlarmId === modelData.id)
                                ? 2
                                : Style.capsuleBorderWidth

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }

                            RowLayout {
                                id: alarmRow
                                anchors {
                                    fill: parent
                                    margins: Style.marginM
                                }
                                spacing: Style.marginM

                                // Bell icon
                                NIcon {
                                    icon: modelData.enabled ? "bell" : "bell-off"
                                    color: modelData.enabled
                                        ? Color.mPrimary
                                        : Color.mOnSurfaceVariant
                                    pointSize: Style.fontSizeM
                                    opacity: modelData.enabled ? 1.0 : 0.5
                                }

                                // Time + label
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    NText {
                                        text: (main?.formatTime(modelData.hour, modelData.minute)) ?? "--:--"
                                        pointSize: Style.fontSizeL
                                        font.weight: Font.Bold
                                        color: modelData.enabled
                                            ? Color.mOnSurface
                                            : Color.mOnSurfaceVariant
                                        opacity: modelData.enabled ? 1.0 : 0.5
                                    }

                                    RowLayout {
                                        spacing: Style.marginXS

                                        NText {
                                            text: modelData.label
                                            pointSize: Style.fontSizeXS
                                            color: Color.mOnSurfaceVariant
                                            opacity: modelData.enabled ? 0.9 : 0.5
                                        }

                                        NText {
                                            visible: modelData.repeat && modelData.days?.length > 0
                                            text: {
                                                if (!modelData.days || modelData.days.length === 0) return ""
                                                var names = root.dayNames
                                                return "· " + modelData.days.map(function(d) {
                                                    return names[d]
                                                }).join(", ")
                                            }
                                            pointSize: Style.fontSizeXS
                                            color: Color.mPrimary
                                            opacity: modelData.enabled ? 1.0 : 0.5
                                        }
                                    }
                                }

                                // Toggle
                                NToggle {
                                    checked: modelData.enabled
                                    onCheckedChanged: {
                                        if (checked !== modelData.enabled) {
                                            main?.toggleAlarm(modelData.id)
                                        }
                                    }
                                }

                                // Delete
                                NIconButton {
                                    icon: "trash"
                                    onClicked: main?.removeAlarm(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
