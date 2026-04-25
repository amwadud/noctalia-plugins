import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    property int snoozeMinutes: pluginApi?.pluginSettings?.snoozeMinutes ?? 5
    property bool notificationEnabled: pluginApi?.pluginSettings?.notificationEnabled ?? true

    function save() {
        pluginApi.pluginSettings.snoozeMinutes = root.snoozeMinutes
        pluginApi.pluginSettings.notificationEnabled = root.notificationEnabled
        pluginApi.saveSettings()
        ToastService.showNotice("Settings saved")
    }

    ColumnLayout {
        anchors { fill: parent; margins: Style.marginL }
        spacing: Style.marginL

        NText {
            text: "Alarm Clock Settings"
            pointSize: Style.fontSizeL
            font.weight: Font.Bold
            color: Color.mOnSurface
        }

        Rectangle {
            Layout.fillWidth: true
            height: col.implicitHeight + Style.marginL * 2
            color: Color.mSurfaceVariant
            radius: Style.radiusL

            ColumnLayout {
                id: col
                anchors { fill: parent; margins: Style.marginL }
                spacing: Style.marginM

                // Notifications toggle
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NText { text: "Toast Notifications"; color: Color.mOnSurface; font.weight: Font.Medium }
                        NText { text: "Show a toast when alarm fires"; color: Color.mOnSurfaceVariant; pointSize: Style.fontSizeXS }
                    }
                    NToggle {
                        checked: root.notificationEnabled
                        onCheckedChanged: root.notificationEnabled = checked
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Style.capsuleBorderColor; opacity: 0.4 }

                // Snooze duration
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NText { text: "Snooze Duration"; color: Color.mOnSurface; font.weight: Font.Medium }
                        NText { text: root.snoozeMinutes + " minutes"; color: Color.mOnSurfaceVariant; pointSize: Style.fontSizeXS }
                    }
                    RowLayout {
                        spacing: Style.marginS
                        NIconButton { icon: "minus"; onClicked: root.snoozeMinutes = Math.max(1, root.snoozeMinutes - 1) }
                        NText { text: root.snoozeMinutes + "m"; font.weight: Font.Bold; color: Color.mOnSurface }
                        NIconButton { icon: "plus"; onClicked: root.snoozeMinutes = Math.min(60, root.snoozeMinutes + 1) }
                    }
                }
            }
        }

        NButton {
            text: "Save Settings"
            Layout.fillWidth: true
            onClicked: root.save()
        }

        Item { Layout.fillHeight: true }
    }
}
