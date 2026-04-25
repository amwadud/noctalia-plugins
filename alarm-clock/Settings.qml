import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // Local copies for editing
    property int snoozeMinutes: pluginApi?.pluginSettings?.snoozeMinutes ?? 5
    property bool soundEnabled: pluginApi?.pluginSettings?.soundEnabled ?? true
    property bool notificationEnabled: pluginApi?.pluginSettings?.notificationEnabled ?? true

    function save() {
        pluginApi.pluginSettings.snoozeMinutes = root.snoozeMinutes
        pluginApi.pluginSettings.soundEnabled = root.soundEnabled
        pluginApi.pluginSettings.notificationEnabled = root.notificationEnabled
        pluginApi.saveSettings()
        ToastService.showNotice("Settings saved")
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Style.marginL
        }
        spacing: Style.marginL

        // ── Header ─────────────────────────────────────────────────────────
        NText {
            text: "Alarm Clock Settings"
            pointSize: Style.fontSizeL
            font.weight: Font.Bold
            color: Color.mOnSurface
        }

        // ── Settings rows ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: settingsCol.implicitHeight + Style.marginL * 2
            color: Color.mSurfaceVariant
            radius: Style.radiusL

            ColumnLayout {
                id: settingsCol
                anchors {
                    fill: parent
                    margins: Style.marginL
                }
                spacing: Style.marginM

                // Sound toggle
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NText {
                            text: "Alarm Sound"
                            color: Color.mOnSurface
                            font.weight: Font.Medium
                        }
                        NText {
                            text: "Play sound when alarm rings"
                            color: Color.mOnSurfaceVariant
                            pointSize: Style.fontSizeXS
                        }
                    }

                    NToggle {
                        checked: root.soundEnabled
                        onCheckedChanged: root.soundEnabled = checked
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.capsuleBorderColor
                    opacity: 0.5
                }

                // Notification toggle
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NText {
                            text: "Toast Notifications"
                            color: Color.mOnSurface
                            font.weight: Font.Medium
                        }
                        NText {
                            text: "Show a toast when alarm triggers"
                            color: Color.mOnSurfaceVariant
                            pointSize: Style.fontSizeXS
                        }
                    }

                    NToggle {
                        checked: root.notificationEnabled
                        onCheckedChanged: root.notificationEnabled = checked
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.capsuleBorderColor
                    opacity: 0.5
                }

                // Snooze duration
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NText {
                            text: "Snooze Duration"
                            color: Color.mOnSurface
                            font.weight: Font.Medium
                        }
                        NText {
                            text: root.snoozeMinutes + " minutes"
                            color: Color.mOnSurfaceVariant
                            pointSize: Style.fontSizeXS
                        }
                    }

                    RowLayout {
                        spacing: Style.marginS

                        NIconButton {
                            icon: "minus"
                            onClicked: root.snoozeMinutes = Math.max(1, root.snoozeMinutes - 1)
                        }

                        NText {
                            text: root.snoozeMinutes + "m"
                            color: Color.mOnSurface
                            font.weight: Font.Bold
                            pointSize: Style.fontSizeM
                        }

                        NIconButton {
                            icon: "plus"
                            onClicked: root.snoozeMinutes = Math.min(60, root.snoozeMinutes + 1)
                        }
                    }
                }
            }
        }

        // ── Save button ─────────────────────────────────────────────────────
        NButton {
            text: "Save Settings"
            Layout.fillWidth: true
            onClicked: root.save()
        }

        // ── Info box ─────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: infoCol.implicitHeight + Style.marginM * 2
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth

            ColumnLayout {
                id: infoCol
                anchors {
                    fill: parent
                    margins: Style.marginM
                }
                spacing: Style.marginXS

                NText {
                    text: "IPC Commands"
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeXS
                    font.weight: Font.Bold
                }

                Repeater {
                    model: [
                        "toggle  — open/close panel",
                        "dismiss — stop ringing alarm",
                        "snooze  — snooze alarm",
                        "add <label> <HH> <MM>"
                    ]
                    NText {
                        text: "· " + modelData
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeXS
                        opacity: 0.7
                    }
                }

                NText {
                    text: "qs -c noctalia-shell ipc call plugin:alarm-clock <cmd>"
                    color: Color.mPrimary
                    pointSize: Style.fontSizeXS
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
