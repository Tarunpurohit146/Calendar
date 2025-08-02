import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: updateCalendarView
    anchors.fill: parent
    color: "gray"
    border.width: 0
    radius: 10

    property var popupHost
    property var currentDate: new Date();
    property int currentMonth: currentDate.getMonth();
    property int currentYear: currentDate.getFullYear();

    signal updateCaledar(var year, var month, var monthName);

    Button {
       id: closeButton
       width: updateCalendarView.width * 0.1
       height: updateCalendarView.height * 0.1
       anchors.top: updateCalendarView.top
       anchors.right: updateCalendarView.right
       anchors.margins: 5
       flat: true

       background: Rectangle {
           color: closeButton.hovered ? "#FF0303" : "#DE3E3E"
           border.width: 0
           radius: closeButton.width / 2
       }

       Text {
           id: buttonText
           text: "X"
           color: "black"
           anchors.centerIn: parent
           font.bold: true
           font.pixelSize: closeButton.width * 0.4
       }

       onClicked: {
           if(popupHost)
               popupHost.close();
       }
    }

    ColumnLayout {
        width: updateCalendarView.width
        height: updateCalendarView.height * 0.8
        anchors.bottom: updateCalendarView.bottom
        spacing: 0

        Button {
            id: yearSelecter
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: updateCalendarView.width * 0.9
            Layout.preferredHeight: updateCalendarView.height * 0.2
            padding: 20;
            flat: true

            background: Rectangle {
                color: yearSelecter.hovered ? Qt.rgba(198/255, 198/255, 198/255, 200/255) : Qt.rgba(198/255, 198/255, 198/255, 150/255);
                border.width: 0
                radius: yearSelecter.width * 0.4
            }

            Text {
                id: yearSelecterText
                text: qsTr(currentYear.toString())
                color: "black"
                anchors.centerIn: parent
                font.bold: true
                font.pixelSize: 18
            }

            MouseArea {
                    id: dragYearArea
                    anchors.fill: parent
                    property real startY

                    onPressed: function(mouse) {
                        startY = mouse.y
                    }
                    onReleased: function(mouse) {
                        let delta = mouse.y - startY;
                        if (Math.abs(delta) > 10) {
                            if (delta > 0) {
                                currentYear--;
                            } else {
                                currentYear++;
                            }
                        }
                    }
              }
        }

        Button {
            id: monthSelecter
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: updateCalendarView.width * 0.9
            Layout.preferredHeight: updateCalendarView.height * 0.2
            padding: 20;
            flat: true

            background: Rectangle {
                color: monthSelecter.hovered ? Qt.rgba(198/255, 198/255, 198/255, 200/255) : Qt.rgba(198/255, 198/255, 198/255, 150/255);
                border.width: 0
                radius: monthSelecter.width * 0.4
            }

            Text {
                id: monthSelecterText
                text: Qt.locale().standaloneMonthName(currentMonth, Locale.LongFormat);
                color: "black"
                anchors.centerIn: parent
                font.bold: true
                font.pixelSize: 18
            }

            MouseArea {
                    id: dragMonthArea
                    anchors.fill: parent
                    property real startY

                    onPressed: function(mouse) {
                        startY = mouse.y
                    }
                    onReleased: function(mouse) {
                        let delta = mouse.y - startY;
                           if (Math.abs(delta) > 10) {
                               currentMonth += (delta > 0) ? -1 : 1;

                               if (currentMonth < 0) {
                                   currentMonth = 11;
                                   currentYear--;
                               } else if (currentMonth > 11) {
                                   currentMonth = 0;
                                   currentYear++;
                               }
                           }
                    }
              }
        }

        Button {
            id: selectButton
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: updateCalendarView.width * 0.9
            Layout.preferredHeight: updateCalendarView.height * 0.2
            padding: 20;
            font.pixelSize: 16
            font.bold: true
            flat: true

            background: Rectangle {
                color: selectButton.hovered ? "#9EA719" : "#A3AA3F";
                border.width: 0
                radius: selectButton.width * 0.4
            }

            Text {
                text: qsTr("Select")
                color: "black"
                anchors.centerIn: parent
                font.bold: true
                font.pixelSize: 18
            }

            onClicked: {
                updateCaledar(yearSelecterText.text, currentMonth, monthSelecterText.text)
                closeButton.clicked()
            }
        }
    }
}
