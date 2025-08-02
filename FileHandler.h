#ifndef FILEHANDLER_H
#define FILEHANDLER_H

#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QByteArray>
#include <QTime>
#include <QDir>

class FileHandler : public QObject
{
    Q_OBJECT

signals:
    void calendarDataReady();

public:
    explicit FileHandler(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void saveEvent(const QString eventText, const QString timeString, const QString yearString, const QString monthString, const QString dateString) {

        event = eventText;
        time = timeString;
        year = yearString;
        month = monthString;
        date = dateString;

        QJsonObject fileContent = readFile();
        if(fileContent.isEmpty())
        {
            QJsonObject data = createNewYearEntry(QJsonObject());
            writeFile(data);
        } else {
            QJsonArray yearArr = fileContent[year].toArray();

            if(yearArr.isEmpty()){
                QJsonObject data = createNewYearEntry(fileContent);
                writeFile(data);
                return;
            }

            QJsonArray monthArr;
            for(const QJsonValue &value : yearArr)
            {
                QJsonObject obj = value.toObject();
                if(obj.contains(month))
                    monthArr = obj[month].toArray();
            }

            if(monthArr.isEmpty()) {
                QJsonObject data = createNewMonthEntry();
                yearArr.append(data);
                fileContent[year] = yearArr;
                writeFile(fileContent);
                return;
            }

            QJsonObject dayObj;
            int dayIndex;

            for(int i=0; i<monthArr.size(); i++)
            {
                QJsonObject obj = monthArr.at(i).toObject();
                if(obj.contains(date)){
                    dayIndex = i;
                    dayObj = obj;
                    break;
                }
            }

            if(dayObj.isEmpty())
            {
                dayObj = createNewDayEntry();
                monthArr.append(dayObj);
            }
            else {

                QJsonArray eventsArr = dayObj[date].toArray();
                bool newEntry = true;
                for(int i=0; i<eventsArr.size(); i++)
                {
                    QJsonObject obj = eventsArr.at(i).toObject();
                    QString savedTime = obj["time"].toString();
                    if(savedTime == time)
                    {
                        obj["event"] = event;
                        eventsArr.replace(i, obj);
                        newEntry = false;
                    }
                }
                if(newEntry) {
                    QJsonObject eventObj = createNewEventEntry();
                    eventsArr.append(eventObj);
                }
                dayObj[date] = eventsArr;
                monthArr[dayIndex] = dayObj;
            }


            QJsonObject monthObj;
            for(int i = 0; i < yearArr.size(); ++i)
            {
                QJsonObject obj = yearArr[i].toObject();
                if(obj.contains(month))
                {
                    obj[month] = monthArr;
                    yearArr[i] = obj; // This line updates the array with modified object
                }
            }
            fileContent[year] = yearArr;
            writeFile(fileContent);
        }
    }

    Q_INVOKABLE void readData()
    {
        calendarContent.clear();
        QJsonObject fileContent = readFile();
        if(fileContent.isEmpty())
        {
            return;
        }


        for(int i=0; i<fileContent.size(); i++)
        {
            QJsonObject obj;
            QString year = fileContent.keys().at(i);
            QJsonArray yearObj = fileContent[year].toArray();
            obj["year"] = year;

            for(int j=0; j<yearObj.size(); j++)
            {

                QJsonObject month = yearObj.at(j).toObject();
                QString monthString = month.keys().at(0);
                QJsonArray monthArr = month[monthString].toArray();
                obj["month"] = monthString;
                for(int z=0; z<monthArr.size(); z++)
                {
                    QJsonObject day = monthArr.at(z).toObject();
                    QString dayString = day.keys().at(0);
                    obj["day"] = dayString;

                    QString key = year+"-"+monthString+"-"+dayString;
                    QStringList values;

                    QJsonArray eventArr = day[dayString].toArray();

                    QList<QJsonObject> eventList;
                    for(int i=0; i<eventArr.size(); i++)
                    {
                        QJsonObject event = eventArr.at(i).toObject();
                        eventList.append(event);
                        calendarEvents[key] = eventList;
                    }

                    calendarContent.append(obj);
                }
            }
        }

        emit calendarDataReady();
    }

    Q_INVOKABLE QList<QJsonObject> calendarData()
    {
        return calendarContent;
    }

    Q_INVOKABLE QList<QJsonObject> getEvent(const QString &key)
    {
        if(calendarEvents.contains(key))
            return calendarEvents.value(key);

        return QList<QJsonObject>();
    }

    Q_INVOKABLE QTime convertStringToTime(const QString &time)
    {
        return QTime::fromString(time, "hh:mm:ss AP");
    }

    QJsonObject createNewYearEntry(QJsonObject parentObj)
    {

        QJsonObject monthObj = createNewMonthEntry();

        QJsonArray yearArray;
        yearArray.append(monthObj);

        if(parentObj.isEmpty()){
            QJsonObject yearObj;
            yearObj[year] = yearArray;
            return yearObj;
        } else {
            parentObj[year] = yearArray;
            return parentObj;
        }


    }

    QJsonObject createNewMonthEntry()
    {

        QJsonObject dayObj = createNewDayEntry();

        QJsonArray monthArr;
        monthArr.append(dayObj);

        QJsonObject monthObj;
        monthObj[month] = monthArr;

        return monthObj;
    }

    QJsonObject createNewDayEntry()
    {
        QJsonObject eventObj = createNewEventEntry();

        QJsonArray eventsArr;
        eventsArr.append(eventObj);
        QJsonObject dayObj;
        dayObj[date] = eventsArr;
        return dayObj;
    }

    QJsonObject createNewEventEntry()
    {
        QJsonObject eventObj;

        eventObj["time"] = time;
        eventObj["event"] = event;

        return eventObj;
    }

    QJsonObject readFile(){
        QFile file(filePath);
        QJsonObject jsonObj;
        if(!file.exists())
        {
            // Create parent directory if needed
            QDir dir = QFileInfo(file).absoluteDir();
            if (!dir.exists()) {
                dir.mkpath(".");
            }

            if (file.open(QIODevice::WriteOnly)) {
                file.close();  // Just create and close
            } else {
                return jsonObj;
            }

        }

        QFile readFile(filePath);
        if(!readFile.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            return jsonObj;
        }

        QByteArray rawData = readFile.readAll();
        readFile.close();

        QJsonDocument jsonData = QJsonDocument::fromJson(rawData);
        if(jsonData.isEmpty())
        {
            return jsonObj;
        }

        jsonObj = jsonData.object();
        return jsonObj;
    }

    void writeFile(QJsonObject &data)
    {
        QFile file(filePath);
        if(!file.open(QIODevice::WriteOnly))
        {
            return;
        }

        QJsonDocument doc(data);
        QByteArray writeData = doc.toJson();
        file.write(writeData);
        file.close();
    }

private:
    const QString filePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/Calendar-Config.json";
    QString event;
    QString time;
    QString year;
    QString month;
    QString date;
    QList<QJsonObject> calendarContent;
    QMap<QString, QList<QJsonObject>> calendarEvents;

};
#endif // FILEHANDLER_H
