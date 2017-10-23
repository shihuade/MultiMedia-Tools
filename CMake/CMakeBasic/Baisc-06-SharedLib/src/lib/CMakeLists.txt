set(LIB_SRC hello.c)

add_library(libhello SHARED ${LIB_SRC})

set_target_properties(libhello PROPERTIES OUTPUT_NAME "hello")
