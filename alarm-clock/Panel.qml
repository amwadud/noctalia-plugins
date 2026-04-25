import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // Required SmartPanel properties (official pattern)
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 420 * Style.uiScaleRatio
    property real contentPreferredHeight: 560 * Style.uiScaleRatio

    anchors.fill: parent

    // Aliases
    readonly property var main: pluginApi?.mainInstance
    readonly property bool isRinging: main?.isRinging ?? false
    readonly property var alarms: main?.alarms ?? []

    // Add form state
    property bool showAddForm: false
    property int newHour: 7
    property int newMinute: 0
    property string newLabel: ""
    property bool newRepeat: false

    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    function resetForm() {
        showAddForm = false
        newLabel = ""
        newHour = 7
        newMinute = 0
        newRepeat = false
    }

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

            // ── Header ────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

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
                }

                NIconButton {
                    icon: root.showAddForm ? "x" : "plus"
                    onClicked: {
                        if (root.showAddForm) root.resetForm()
                        else root.showAddForm = true
                    }
                }
            }

            // ── Ringing Banner ────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                visible: root.isRinging
                height: visible ? 72 * Style.uiScaleRatio : 0
                color: Color.mPrimary
                radius: Style.radiusL

                SequentialAnimation on opacity {
                    running: root.isRinging
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.7; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutSine }
                }

                RowLayout {
                    anchors { fill: parent; margins: Style.marginM }
                    spacing: Style.marginM

                    NIcon {
                        icon: "bell-ringing"
                        color: Color.mOnPrimary
                        pointSize: Style.fontSizeL
                    }

                    NText {
                        text: "Alarm ringing!"
                        color: Color.mOnPrimary
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeM
                        Layout.fillWidth: true
                    }

                    NButton {
                        text: "Snooze"
                        onClicked: main?.snoozeAlarm()
                    }

                    NButton {
                        text: "Dismiss"
                        onClicked: main?.dismissAlarm()
                    }
                }
            }

            // ── Add Form ──────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                visible: root.showAddForm
                height: visible ? formCol.implicitHeight + Style.marginL * 2 : 0
                color: Color.mSurfaceVariant
                radius: Style.radiusL

                ColumnLayout {
                    id: formCol
                    anchors { fill: parent; margins: Style.marginL }
                    spacing: Style.marginM

                    NText {
                        text: "New Alarm"
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeM
                        color: Color.mOnSurface
                    }

                    NTextInput {
                        id: labelInput
                        Layout.fillWidth: true
                        label: "Label"
                        placeholderText: "Wake up"
                        onTextChanged: root.newLabel = text
                    }

                    // Time row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        NText { text: "Time:"; color: Color.mOnSurfaceVariant }

                        // Hour
                        Rectangle {
                            width: 64 * Style.uiScaleRatio
                            height: 32 * Style.uiScaleRatio
                            color: Color.mSurface
                            radius: Style.radiusM
                            border.color: Style.capsuleBorderColor
                            border.width: Style.capsuleBorderWidth

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                NIconButton {
                                    icon: "chevron-left"
                                    Layout.fillHeight: true
                                    onClicked: root.newHour = (root.newHour + 23) % 24
                                }
                                NText {
                                    text: main?.pad(root.newHour) ?? "07"
                                    font.weight: Font.Bold
                                    color: Color.mOnSurface
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                NIconButton {
                                    icon: "chevron-right"
                                    Layout.fillHeight: true
                                    onClicked: root.newHour = (root.newHour + 1) % 24
                                }
                            }
                        }

                        NText { text: ":"; font.weight: Font.Bold; color: Color.mOnSurface; pointSize: Style.fontSizeM }

                        // Minute
                        Rectangle {
                            width: 64 * Style.uiScaleRatio
                            height: 32 * Style.uiScaleRatio
                            color: Color.mSurface
                            radius: Style.radiusM
                            border.color: Style.capsuleBorderColor
                            border.width: Style.capsuleBorderWidth

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                NIconButton {
                                    icon: "chevron-left"
                                    Layout.fillHeight: true
                                    onClicked: root.newMinute = (root.newMinute + 59) % 60
                                }
                                NText {
                                    text: main?.pad(root.newMinute) ?? "00"
                                    font.weight: Font.Bold
                                    color: Color.mOnSurface
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                NIconButton {
                                    icon: "chevron-right"
                                    Layout.fillHeight: true
                                    onClicked: root.newMinute = (root.newMinute + 1) % 60
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Repeat toggle
                    RowLayout {
                        Layout.fillWidth: true
                        NText { text: "Repeat daily"; color: Color.mOnSurfaceVariant; Layout.fillWidth: true }
                        NToggle {
                            checked: root.newRepeat
                            onCheckedChanged: root.newRepeat = checked
                        }
                    }

                    // Buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS
                        NButton {
                            text: "Cancel"
                            Layout.fillWidth: true
                            onClicked: root.resetForm()
                        }
                        NButton {
                            text: "Add"
                            Layout.fillWidth: true
                            onClicked: {
                                main?.addAlarm(root.newLabel || "Alarm", root.newHour, root.newMinute, root.newRepeat)
                                root.resetForm()
                                labelInput.text = ""
                            }
                        }
                    }
                }
            }

            // ── Alarm list ────────────────────────────────────────────────────
            NScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: Style.marginS

                    // Empty state
                    Item {
                        Layout.fillWidth: true
                        height: 100 * Style.uiScaleRatio
                        visible: root.alarms.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS

                            NIcon {
                                icon: "bell-off"
                                color: Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeXXL
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.4
                            }
                            NText {
                                text: "No alarms — tap + to add one"
                                color: Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeS
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.6
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
                            color: modelData.enabled ? Color.mSurfaceVariant : Color.mSurface
                            border.color: (main?.ringingAlarmId === modelData.id) ? Color.mPrimary : Style.capsuleBorderColor
                            border.width: (main?.ringingAlarmId === modelData.id) ? 2 : Style.capsuleBorderWidth

                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                id: alarmRow
                                anchors { fill: parent; margins: Style.marginM }
                                spacing: Style.marginM

                                NIcon {
                                    icon: modelData.enabled ? "bell" : "bell-off"
                                    color: modelData.enabled ? Color.mPrimary : Color.mOnSurfaceVariant
                                    pointSize: Style.fontSizeM
                                    opacity: modelData.enabled ? 1.0 : 0.5
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    NText {
                                        text: (main?.formatTime(modelData.hour, modelData.minute)) ?? "--:--"
                                        pointSize: Style.fontSizeL
                                        font.weight: Font.Bold
                                        color: modelData.enabled ? Color.mOnSurface : Color.mOnSurfaceVariant
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
                                            visible: modelData.repeat
                                            text: "· Daily"
                                            pointSize: Style.fontSizeXS
                                            color: Color.mPrimary
                                        }
                                    }
                                }

                                NToggle {
                                    checked: modelData.enabled
                                    onCheckedChanged: {
                                        if (checked !== modelData.enabled)
                                            main?.toggleAlarm(modelData.id)
                                    }
                                }

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
