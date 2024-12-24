# Build a static library named mylib. Notice that interface header files are included in the library target.
add_library(mylib STATIC mylib.cpp mylib.h)

# Add include path which user of this library can use
target_include_directories(mylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})