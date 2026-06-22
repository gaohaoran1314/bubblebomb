cmake_minimum_required(VERSION 4.1.1)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
set(CMAKE_CXX_MODULE_STD ON)

project(bubblebomb VERSION 0.1 LANGUAGES CXX)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)
qt_standard_project_setup(REQUIRES 6.7)

qt_add_executable(appbubblebomb WIN32)
qt_add_qml_module(appbubblebomb
    URI bubblebomb
    VERSION 1.0
    SOURCES     main.cpp
                NetworkManager.cpp
                NetworkManager.h
    QML_FILES   Main.qml
                Game.qml
                Player.qml
                Block.qml
                Bomb.qml
                Monster.qml
                Wall.qml
                PowerUp.qml
                Music.qml
                Lobby.qml
                KeyBindings.qml
                VolumeControl.qml
                KeyConfig.qml
                PauseOverlay.qml
)

qt_add_resources(appbubblebomb "resources"
    PREFIX "/"
    FILES
        sounds/bombmusic.wav
        sounds/bgm.mp3
        sounds/hit.wav
        sounds/put.wav
        sounds/victory.wav
        sounds/lose.wav

)

target_compile_features(appbubblebomb PRIVATE cxx_std_23)

target_link_libraries(appbubblebomb PRIVATE Qt6::Multimedia)

set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}" CACHE PATH "Install path prefix" FORCE)
install(TARGETS appbubblebomb
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# C++ Modules support
set(BUBBLEBOMB_MODULE_FILES
    # math.cppm
)
source_group("bubblebomb" FILES ${BUBBLEBOMB_MODULE_FILES})
target_sources(appbubblebomb
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES
        BASE_DIRS   ${CMAKE_CURRENT_SOURCE_DIR}
        FILES  ${BUBBLEBOMB_MODULE_FILES}
)
