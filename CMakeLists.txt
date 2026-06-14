cmake_minimum_required(VERSION 4.1.1)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
# cmake_minimum_required(VERSION 4.3.2)
# set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
set(CMAKE_CXX_MODULE_STD ON)

project(bubblebomb VERSION 0.1 LANGUAGES CXX)
set(QT_QML_GENERATE_QMLLS_INI ON)

# 改动1：添加 Multimedia 组件
find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)
qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appbubblebomb WIN32)
qt_add_qml_module(appbubblebomb
    URI bubblebomb
    VERSION 1.0
    SOURCES     main.cpp
    QML_FILES   Main.qml
                Game.qml
                Player.qml
                Block.qml
                Bomb.qml
                Monster.qml
                Wall.qml
                PowerUp.qml
                Music.qml


)
target_compile_features(appbubblebomb PRIVATE cxx_std_23)

# 改动2：qt_add_qml_module 已自动链接 Qt6::Quick, Qt6::Core, Qt6::Qml, Qt6::Gui，
# 只需额外添加 Multimedia
target_link_libraries(appbubblebomb PRIVATE Qt6::Multimedia)

set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}" CACHE PATH "Install path prefix" FORCE)
install(TARGETS appbubblebomb
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# C++ Modules support
set(BUBBLEBOMB_MODULE_FILES
    # math.cppm                             # 模块文件
)
source_group("bubblebomb" FILES ${BUBBLEBOMB_MODULE_FILES})
target_sources(appbubblebomb
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES
        BASE_DIRS   ${CMAKE_CURRENT_SOURCE_DIR}
        FILES  ${BUBBLEBOMB_MODULE_FILES}
)