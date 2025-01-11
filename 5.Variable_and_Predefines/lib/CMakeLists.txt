# Build a static library named mylib. Notice that interface header files are included in the library target.
add_library(mylib STATIC mylib.cpp mylib.h)

# Optionally, set include paths for this library
target_include_directories(mylib 
PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
)