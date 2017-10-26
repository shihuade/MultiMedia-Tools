
cmake_minimum_required(VERSION 3.8)

set( CMAKE_VERBOSE_MAKEFILE on )
set(CMAKE_BUILD_TYPE Debug)
#set(CMAKE_BUILD_TYPE Release)

project(HELLO)

set(APP_SRC main.c)

set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

link_directories(./lib)
include_directories(./)

add_executable(hello ${APP_SRC})
target_link_libraries(hello libhello.a)



#**********************************************************************************
# setting which not work
#**********************************************************************************
#SET( CMAKE_EXE_LINKER_FLAGS   "-L${PROJECT_SOURCE_DIR}/lib")
#link_libraries(libhello)
#add_dependencies(libhello)
#set_target_properties(libhello PROPERTIES OUTPUT_NAME "hello")
#target_link_libraries(hello libhello.a)
#**********************************************************************************
