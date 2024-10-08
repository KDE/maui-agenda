# Copyright 2018-2021 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2021 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

set(project_SRCS
    code/main.cpp
    assets/assets.qrc)

qt_add_executable(${PROJECT_NAME}
    ${project_SRCS})

qt_add_qml_module(${PROJECT_NAME} URI app.maui.agenda
    NO_PLUGIN
    QML_FILES
    controls/main.qml)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::Calendar

    Qt6::Core
    Qt6::Quick
    Qt6::Widgets

    KF6::CoreAddons
    KF6::I18n)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
