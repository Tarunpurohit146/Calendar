import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {

    id: eventRect
    width: parent.width
    height: parent.height
    color: "gray"

    property var popupHost
    property var preTime: ""
    property var now: !preTime ? new Date() : preTime
    property var meridiem: now.getHours() >= 12 ? "PM" : "AM"
    property var currentHrs: ((now.getHours() % 12) === 0 ? 12 : now.getHours() % 12).toString().padStart(2, "0");
    property var currentMin: now.getMinutes().toString().padStart(2, "0")
    property var currentSec: now.getSeconds().toString().padStart(2, "0")
    property var preEvent: ""

    signal sendValues(var event, var hours, var minutes, var seconds, var meridiem)


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: eventTextRect
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width * 0.9
            Layout.preferredHeight: parent.height * 0.45

            Rectangle {
                id: backgroundRect
                anchors.centerIn: parent
                width: eventRect.width * 0.9
                height: eventRect.height * 0.45
                radius: 10
                color: "#D9D9D9"

                TextInput {
                    id: eventText
                    anchors.fill: parent
                    anchors.margins: 20
                    wrapMode: Text.Wrap
                    text: preEvent
                    font.pixelSize: 16
                    font.bold: true
                    activeFocusOnPress: true
                    color: "black"
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    onFocusChanged: function(focus) {
                        var textLength = eventText.text.length;
                        if (focus) {
                            Qt.inputMethod.show(); // Force keyboard
                            if (textLength <= 0) {
                                eventText.horizontalAlignment = TextInput.AlignLeft;
                                eventText.verticalAlignment = TextInput.AlignTop;
                            }
                        } else {
                            if (textLength <= 0) {
                                eventText.horizontalAlignment = TextInput.AlignHCenter;
                                eventText.verticalAlignment = TextInput.AlignVCenter;
                            }
                        }
                    }
                }

                // Simulated placeholder
                Text {
                    text: "Event"
                    anchors.fill: parent
                    anchors.margins: 20
                    font.pixelSize: 16
                    font.bold: true
                    color: "#888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: eventText.text.length === 0 && !eventText.activeFocus
                    z: 1
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width * 0.95
            Layout.preferredHeight: parent.height * 0.25
            color: "gray"


            RowLayout {
                anchors.fill: parent
                spacing: 2

                Button {
                    id: hrsButton
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.preferredHeight: parent.height * 0.8
                    text: currentHrs
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                        radius: 10
                        color: "#D9D9D9"
                    }

                    property int animHrs: 0
                    property int targetHrs: 0

                    MouseArea {
                        id: hrsButtonMouse
                        anchors.fill: parent
                        property real startX
                        property int sensitivity: 25  // pixels per hour change

                        onPressed: function(mouse) {
                            startX = mouse.x
                        }

                        onReleased: function(mouse) {
                            let deltaX = mouse.x - startX
                            let hrs = parseInt(currentHrs)

                            let change = Math.floor(deltaX / sensitivity)
                            if (change !== 0) {
                                hrs += change

                                // Wrap around 0–12 (assuming 12-hour format)
                                if (hrs < 0)
                                    hrs = (hrs + 13) % 13  // allows hrs=0 to cycle correctly
                                else if (hrs > 12)
                                    hrs = hrs % 13

                                hrsButton.animHrs = parseInt(currentHrs)
                                hrsButton.targetHrs = hrs
                                animTimerHrs.start()
                                //currentHrs = hrs.toString().padStart(2, "0")
                            }
                        }
                        Timer {
                            id: animTimerHrs
                            interval: 50  // ms between steps
                            repeat: true
                            onTriggered: {

                                if (hrsButton.animHrs < hrsButton.targetHrs) {
                                    hrsButton.animHrs += 1
                                } else if (hrsButton.animHrs > hrsButton.targetHrs) {
                                    hrsButton.animHrs -= 1
                                } else {
                                    animTimerHrs.stop()
                                }
                                currentHrs = hrsButton.animHrs.toString().padStart(2, "0")
                            }
                        }

                    }
                }

                Button {
                    id: minButton
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.preferredHeight: parent.height * 0.8
                    text: currentMin
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                           radius: 10
                           color: "#D9D9D9"
                    }

                    property int animMin: 0
                    property int targetMin: 0

                    MouseArea {
                        id: minButtonMouse
                        anchors.fill: parent
                        property real startX
                        property int sensitivity: 25  // pixels per unit change

                        onPressed: function(mouse) {
                            startX = mouse.x
                        }

                        onReleased: function(mouse) {
                            let deltaX = mouse.x - startX
                            let min = parseInt(currentMin)

                            let change = Math.floor(deltaX / sensitivity)
                            if (change !== 0) {
                                min += change

                                if (min < 0)
                                    min = (min + 60) % 60
                                else if (min > 59)
                                    min = min % 60

                                //currentMin = min.toString().padStart(2, "0")
                                minButton.animMin = parseInt(currentMin)
                                minButton.targetMin = min

                                animTimerMin.start()

                            }
                        }
                    }

                    Timer {
                        id: animTimerMin
                        interval: 50  // ms between steps
                        repeat: true
                        onTriggered: {

                            if (minButton.animMin < minButton.targetMin) {
                                minButton.animMin += 1
                            } else if (minButton.animMin > minButton.targetMin) {
                                minButton.animMin -= 1
                            } else {
                                animTimerMin.stop()
                            }

                            currentMin = minButton.animMin.toString().padStart(2, "0")
                        }
                    }

                }

                Button {
                    id: seconds
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.preferredHeight: parent.height * 0.8
                    text: currentSec
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                        radius: 10
                        color: "#D9D9D9"
                    }

                    property int animSec: 0
                    property int targetSec: 0

                    MouseArea {
                        id: secButtonMouse
                        anchors.fill: parent
                        property real startX
                        property int sensitivity: 20  // pixels per unit change

                        onPressed: function(mouse) {
                            startX = mouse.x
                        }

                        onReleased: function(mouse) {
                            let deltaX = mouse.x - startX
                            let sec = parseInt(currentSec)

                            // Change seconds by delta/sensitivity
                            let change = Math.floor(deltaX / sensitivity)
                            if (change !== 0) {
                                sec += change

                                // Wrap the value between 0–59
                                if (sec < 0)
                                    sec = (sec + 60) % 60
                                else if (sec > 59)
                                    sec = sec % 60

                                seconds.animSec = parseInt(currentSec)
                                seconds.targetSec = sec
                                animTimerSec.start()
                                //currentSec = sec.toString().padStart(2, "0")
                            }
                        }
                    }
                    Timer {
                       id: animTimerSec
                       interval: 50  // ms between steps
                       repeat: true
                       onTriggered: {
                           if (seconds.animSec < seconds.targetSec) {
                               seconds.animSec += 1
                           } else if (seconds.animSec > seconds.targetSec) {
                              seconds.animSec -= 1
                           } else {
                               animTimerSec.stop()
                           }
                           currentSec = seconds.animSec.toString().padStart(2, "0")
                       }
                   }
                }

                Button {
                    id: button
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.preferredHeight: parent.height * 0.8
                    text: meridiem
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                        radius: 10
                        color: "#D9D9D9"
                    }

                    MouseArea {
                        id: meridiemMouse
                        anchors.fill: parent
                        property real startY
                        property real startX

                        onPressed: function(mouse) {
                            startY = mouse.y
                            startX = mouse.x
                        }

                        onReleased: function(mouse) {
                            let deltaY = mouse.y - startY
                            let deltaX = mouse.x - startX

                            if (Math.abs(deltaX) > 10) {
                                // Horizontal swipe logic
                                if (deltaX > 0) {
                                    meridiem = "AM"
                                    // Implement your right swipe action here
                                } else {
                                    meridiem = "PM"
                                    // Implement your left swipe action here
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width * 0.9
            Layout.preferredHeight: parent.height * 0.2
            color: "gray"

            RowLayout {
                anchors.fill: parent

                Button {
                    id: submitButton
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.height * 0.8
                    Layout.bottomMargin: 10
                    text: "submit"
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                           radius: 10
                    }

                    onClicked: {
                        if(eventText.text.length > 0)
                        {
                            sendValues(eventText.text, currentHrs, currentMin, currentSec, meridiem)
                            closeButton.clicked()
                        }

                    }

                }

                Button {
                    id: closeButton
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.height * 0.8
                    Layout.bottomMargin: 10
                    text: "Close"
                    padding: 20
                    font.pixelSize: 16
                    font.bold: true
                    flat: true

                    background: Rectangle {
                           radius: 10
                    }

                    onClicked: {
                        if(popupHost)
                            popupHost.visible = false
                    }

                }
            }

        }
    }
}
