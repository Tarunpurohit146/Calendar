import QtQuick

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Rounded Image Example")

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: "CalendarWidget.qml"
        onLoaded: {
            pageLoader.item.parentLoader = pageLoader
        }

    }
}
