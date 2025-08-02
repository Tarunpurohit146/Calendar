cmake_minimum_required(VERSION 3.16)

project(Calendar VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick multimedia MultimediaWidgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appCalendar
    main.cpp
)

qt_add_qml_module(appCalendar
    URI Calendar
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES CalendarWidget.qml
        QML_FILES UpdateCalendar.qml
        SOURCES FileHandler.h
        QML_FILES Event.qml
        RESOURCES Resource.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appCalendar PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCalendar
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCalendar
    PRIVATE Qt6::Quick
    Qt6::Multimedia
    Qt6::MultimediaWidgets
)

include(GNUInstallDirs)
install(TARGETS appCalendar
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
