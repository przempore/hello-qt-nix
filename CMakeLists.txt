# generate simple cmakelists.txt

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(hello-qt LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/compile_commands.json ${CMAKE_SOURCE_DIR}/compile_commands.json)

set(Qt5_DIR $ENV{QT_DIR}/5.15.15/gcc_64)
message(STATUS "CMAKE_PREFIX_PATH: ${Qt5_DIR}")
find_package(Qt5 COMPONENTS Core REQUIRED PATHS ${Qt5_DIR} NO_DEFAULT_PATH)

add_executable(hello-qt hello-qt.cpp)

set_property(TARGET hello-qt PROPERTY CXX_STANDARD 20)
set_property(TARGET hello-qt PROPERTY CXX_STANDARD_REQUIRED ON)

target_link_libraries(hello-qt Qt5::Core)
