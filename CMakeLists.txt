# generate simple cmakelists.txt

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(hello-qt LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/compile_commands.json ${CMAKE_SOURCE_DIR}/compile_commands.json)

set(QT_DIR $ENV{QT_DIR}/5.15.15/gcc_64)
message(STATUS "QT_DIR: ${QT_DIR}")
find_package(Qt5 COMPONENTS Core REQUIRED PATHS ${QT_DIR} NO_DEFAULT_PATH)
find_package(Boost COMPONENTS container REQUIRED)

message(STATUS "CVB_VERSION: $ENV{CVB_VERSION}")
set(ENV{CVB} "${CMAKE_SOURCE_DIR}/cvb/unpacked/opt/cvb-$ENV{CVB_VERSION}")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_SOURCE_DIR}/cvb/unpacked/opt/cvb-$ENV{CVB_VERSION}/cmake" CACHE STRING "Modules for CMake" FORCE)
message(STATUS "CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")
find_package(CVB REQUIRED)

add_executable(hello-qt hello-qt.cpp)

set_property(TARGET hello-qt PROPERTY CXX_STANDARD 20)
set_property(TARGET hello-qt PROPERTY CXX_STANDARD_REQUIRED ON)

target_link_libraries(hello-qt Qt5::Core CVB::CVCUtilities CVB::CVCore CVB::CVCImg Boost::container)
