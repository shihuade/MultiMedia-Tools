#ifndef _HELLO_
#define _HELLO_

#if defined _WIN32
    #if LIBHELLO_BUILD
        #define LIBHELLO_API __declspec(dllexport)
    #else
        #define LIBHELLO_API __declspec(dllimport)
    #endif
#else
    #define LIBHELLO_API
#endif

LIBHELLO_API void sayhello();

#endif
