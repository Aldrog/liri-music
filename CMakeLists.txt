cmake_minimum_required(VERSION 2.8)
project(liri-vinyl)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

find_package(Qt5 COMPONENTS Core Gui Sql Quick Qml Svg WebEngine REQUIRED)
find_package(Taglib REQUIRED)
find_package(Qt5GStreamer REQUIRED)

include(material/vendor.cmake)

include_directories(${TAGLIB_INCLUDE_DIRS})
include_directories(${QTGSTREAMER_INCLUDE_DIR})

add_subdirectory(src)
