#*************************************
# cmake version
#*************************************
cmake_minimum_required(VERSION 3.8)
#*************************************

project(HELLO)

#*************************************
# set output bin/lib path
#*************************************
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
#*************************************

add_subdirectory(src)
