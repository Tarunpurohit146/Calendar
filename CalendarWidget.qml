import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: calendar
    anchors.fill: parent
    color: "#2A2929"

    property var currentDate: new Date()
    property int currentYear: currentDate.getFullYear()
    property Loader parentLoader

    ScrollView {
        id: scroller
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        contentWidth: calendar.width
        clip: true

        ColumnLayout {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: calendar.width * 0.9
                        Layout.preferredHeight: calendar.height * 0.2
                        Layout.alignment: Qt.AlignHCenter
                        color: Qt.rgba(199/255, 198/255, 198/255, 100/255)
                        radius: 10
                        border.width: 0
                        Layout.topMargin: 10
                        Layout.bottomMargin: 0

                        Text {
                            id: dateText
                            text: qsTr(currentDate.toDateString())
                            anchors.centerIn: parent
                            color: "white"
                            font.bold: true
                            font.pixelSize: parent.width * 0.1
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                grid.month = currentDate.getMonth();
                                grid.year = currentDate.getFullYear();
                            }
                        }
                    }
                    Rectangle {
                        id: dateControler
                        Layout.preferredWidth: calendar.width * 0.9
                        Layout.preferredHeight: calendar.height * 0.1
                        Layout.alignment: Qt.AlignHCenter
                        color: Qt.rgba(199/255, 198/255, 198/255, 100/255)
                        radius: 10
                        border.width: 0

                        RowLayout {
                            anchors.fill: dateControler

                            Button {
                                id: prevMonth
                                Layout.preferredWidth: dateControler.height * 0.9
                                Layout.preferredHeight: dateControler.height * 0.9
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 10
                                flat: true
                                padding: 0

                                background: Rectangle {
                                    color: Qt.rgba(217/255, 217/255, 217/255, 100/217)
                                    radius: prevMonth.width / 2
                                }

                                Text {
                                    text: qsTr("<")
                                    font.bold: true
                                    font.pixelSize: 24
                                    anchors.centerIn: parent
                                    bottomPadding: 4
                                }

                                onClicked: {
                                    var currentMonth = grid.month;
                                    currentMonth--;
                                    if(currentMonth < 0){
                                       currentMonth = 11;
                                        grid.year--;
                                    }
                                    grid.month = currentMonth;
                                    var monthName = locale.standaloneMonthName(currentMonth, Locale.LongFormat);
                                    calendarText.text = monthName+" "+grid.year
                                }
                            }

                            Text {
                                id: calendarText
                                text: qsTr(Qt.locale().standaloneMonthName(currentDate.getMonth(), Locale.LongFormat)+"  "+currentDate.getFullYear().toString())
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                color: "white"
                                font.bold: true
                                font.pixelSize: 18

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        customPopup.open();
                                        eventViewRect.visible = false
                                        eventRect.visible = false
                                    }
                                }
                            }

                            Button {
                                id: nextMonth
                                Layout.preferredWidth: dateControler.height * 0.9
                                Layout.preferredHeight: dateControler.height * 0.9
                                Layout.alignment: Qt.AlignVCenter
                                Layout.rightMargin: 10
                                flat: true

                                background: Rectangle {
                                    color: Qt.rgba(217/255, 217/255, 217/255, 100/217)
                                    radius: nextMonth.width / 2
                                }

                                Text {
                                    text: qsTr(">")
                                    font.bold: true
                                    font.pixelSize: 24
                                    anchors.centerIn: parent
                                    bottomPadding: 4
                                }
                                onClicked: {
                                    var currentMonth = grid.month;
                                    currentMonth++;
                                    if(currentMonth > 11){
                                       currentMonth = 0;
                                        grid.year++;
                                    }
                                    grid.month = currentMonth;
                                    var monthName = locale.standaloneMonthName(currentMonth, Locale.LongFormat);
                                    calendarText.text = monthName+" "+grid.year
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: daysRect
                        Layout.preferredWidth: calendar.width * 0.9
                        Layout.preferredHeight: calendar.height * 0.6
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        color: Qt.rgba(199/255, 198/255, 198/255, 100/255)
                        radius: 10
                        border.width: 0


                        property date selectedDate: new Date()

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            DayOfWeekRow {
                                Layout.fillWidth: true
                                locale: grid.locale
                                delegate: Text {
                                    text: shortName
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    required property string shortName
                                }
                            }

                            MonthGrid {
                                id: grid
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                padding: 10

                                property var specialDates: ({})


                                delegate: Item {
                                    id: delegateItem

                                    property bool isSelectedDay: (
                                        model.year === daysRect.selectedDate.getFullYear() &&
                                        model.month === daysRect.selectedDate.getMonth() &&
                                        model.day === daysRect.selectedDate.getDate()
                                    )

                                    property bool isCurrentMonth: model.month === grid.month

                                    property bool isSpecialDay: {
                                        for (var i = 0; i < grid.specialDates.length; ++i) {
                                            var entry = grid.specialDates[i]
                                            if (parseInt(entry["year"]) === model.year &&
                                                parseInt(entry["month"]) === model.month &&
                                                parseInt(entry["day"]) === model.day) {
                                                return true;
                                            }
                                        }
                                        return false;
                                    }

                                    Rectangle {
                                        id: dayText
                                        anchors.fill: parent
                                        color: delegateItem.isSpecialDay ? "#FF8C00"
                                                  : delegateItem.isSelectedDay ? "lightblue"
                                                  : delegateItem.isCurrentMonth ? "#333333"
                                                  : "#5F5F5F"

                                       border.width: 0;
                                       radius: dayText.width / 2

                                        Text {
                                            anchors.centerIn: parent
                                            color: delegateItem.isSpecialDay ? "white"
                                                 : delegateItem.isSelectedDay ? "black"
                                                  : delegateItem.isCurrentMonth ? "white"
                                                  : "black"
                                            text: model.day
                                        }
                                    }
                                }

                                onClicked: function(date) {
                                    if (date.getMonth() === grid.month) {

                                        var selectedDate = grid.year+"-"+grid.month+"-"+date.getDate();
                                        var selectedDateEvent = fileHandler.getEvent(selectedDate)

                                        eventRect.eventData = selectedDateEvent
                                        if(daysRect.selectedDate.getDate() === date.getDate() && eventRect.visible){
                                            eventLoader.item.preEvent = ""
                                            eventLoader.item.preTime = ""
                                            eventViewRect.visible = false
                                            eventRect.visible = false
                                        } else {
                                            eventRect.visible = true
                                        }
                                        daysRect.selectedDate = date;

                                    } else {
                                        eventRect.visible = false
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: eventRect
                        visible: false
                        Layout.preferredWidth: calendar.width * 0.9

                        implicitHeight: columnInside.implicitHeight * 1.5
                        Layout.alignment: Qt.AlignHCenter
                        color: Qt.rgba(199/255, 198/255, 198/255, 100/255)
                        radius: 10
                        border.width: 0

                        onVisibleChanged: {
                            if(visible) {
                                Qt.callLater(scroller.scrollToBottom)
                            } else {
                                Qt.callLater(scroller.scrollToTop)
                            }

                        }

                        property var eventData : ({})

                        ColumnLayout {
                            id: columnInside
                            anchors.fill: parent
                            spacing: 2

                            Repeater {
                                model: eventRect.eventData
                                delegate: Button {
                                    Layout.preferredWidth: eventRect.width * 0.8
                                    Layout.alignment: Qt.AlignCenter
                                    flat: true

                                    background: Rectangle {
                                        color: "#D9D9D9"
                                        radius: 6
                                    }

                                    contentItem: Text {
                                        text: modelData.event
                                        color: "black"
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        wrapMode: Text.Wrap
                                        padding: 5
                                    }
                                    Text {
                                        id: timeDisplayText
                                        text: modelData.time
                                        color: "black"
                                        font.pixelSize: 12
                                        anchors.fill: parent
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignBottom
                                        anchors.rightMargin: 5
                                        anchors.bottomMargin: 5
                                    }

                                    onClicked: {
                                        eventLoader.item.preEvent = modelData.event
                                        var timefromString = fileHandler.convertStringToTime(modelData.time);
                                        eventLoader.item.preTime = fileHandler.convertStringToTime(modelData.time);
                                        updateCalendarLoader.source = ""
                                        eventViewRect.visible = true
                                        // Add your action here
                                    }
                                }
                            }

                            Button {
                                id: addEventButton

                                Layout.preferredWidth: eventRect.width * 0.8
                                Layout.alignment: Qt.AlignCenter
                                flat: true
                                background: Rectangle {
                                    color: addEventButton.hovered ? "#919090" : "#D9D9D9"
                                    radius: 6
                                }

                                contentItem: Text {
                                    id: addEventButtonText
                                    text: qsTr("Add Event")
                                    color: "black"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    anchors.fill: parent
                                    anchors.margins: 12
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        var preEvent = eventLoader.item.preEvent

                                        eventLoader.item.preEvent = ""
                                        eventLoader.item.preTime = ""

                                        if(preEvent.length > 0)
                                        {
                                            return;
                                        }
                                        if(eventViewRect.visible === false)
                                            eventViewRect.visible = true
                                        else
                                            eventViewRect.visible = false
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: eventViewRect
                        Layout.preferredWidth: calendar.width * 0.9
                        implicitHeight: calendar.height * 0.4
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 10
                        color: Qt.rgba(199/255, 198/255, 198/255, 100/255)
                        border.width: 0
                        visible: false

                        onVisibleChanged: {
                            if(visible)
                            {
                                Qt.callLater(scroller.scrollToBottom)
                            } else {
                                Qt.callLater(scroller.scrollToTop)
                            }
                        }

                        Loader {
                            id: eventLoader
                            anchors.fill: parent
                            source: "Event.qml"

                            onLoaded: {
                                if (item) {
                                    item.popupHost = eventViewRect
                                    //item.selectedDate = selectedDate;
                                    item.sendValues.connect(function(event, hours, minute, seconds, meridiem) {
                                        var time = hours+":"+minute+":"+seconds+" "+meridiem

                                        fileHandler.saveEvent(event, time, grid.year, grid.month, daysRect.selectedDate.getDate())
                                        fileHandler.readData()
                                    })
                                }

                            }
                        }

                    }
        }
        function scrollToBottom() {
            ScrollBar.vertical.position = 1.0 - ScrollBar.vertical.size
        }
        function scrollToTop()
        {
            ScrollBar.vertical.position = 1.0 + ScrollBar.vertical.size
        }
    }

    Component.onCompleted: {
        fileHandler.readData()
    }

    Connections {
        target: fileHandler
        function onCalendarDataReady() {
            grid.specialDates = fileHandler.calendarData()
            if(eventRect.visible)
            {
                var selectedDate = grid.year+"-"+grid.month+"-"+daysRect.selectedDate.getDate()

                var selectedDateEvent = fileHandler.getEvent(selectedDate)

                eventRect.eventData = selectedDateEvent
                grid.update()
            }
        }
    }

    Popup {
        id: customPopup
        modal: true
        width: parent.width * 0.6
        height: parent.height * 0.4
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Loader {
            id: updateCalendarLoader
            source: "UpdateCalendar.qml"
            anchors.fill: parent
            onLoaded: {
                if (item) {
                    item.popupHost = customPopup

                    item.updateCaledar.connect(function(year, month, monthName) {
                        grid.year = year
                        grid.month = month
                        calendarText.text = monthName + " " + year
                    })
                }
            }
        }

        background: Rectangle {
            color: "#2A2929"
            border.width: 0
            radius: 10
        }
    }
}
