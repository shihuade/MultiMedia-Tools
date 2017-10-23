project(HELLO)

include_directories(${PROJECT_SOURCE_DIR}/src/lib)

set(APP_SRC main.c)

add_executable(hello ${APP_SRC})

target_link_libraries(hello libhello)
