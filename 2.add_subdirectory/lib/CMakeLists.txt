# Build a static library named mylib. Notice that interface header files are included in the library target.
add_library(mylib 
STATIC 
    mylib.cpp 
    mylib.h
)
# Included header file help
## 1. Dependency tracking whenever header file changes cause user of this library to recompile. (Ninja seems depency tracking pretty well even without this but it is better to provide this information)
## 2. IDEs can use this information to provide code completion.

# Add include path which for itself and user of this library can use.
target_include_directories(mylib
# PRIVATE # It is better to include only one PRIVATE directory.
#     ${CMAKE_CURRENT_SOURCE_DIR}
PUBLIC  # it is better to include only one PUBLIC directory.
#    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR} 
    ${CMAKE_CURRENT_SOURCE_DIR}/dummy_inc # User also may include this directory. So, limit the PUBLIC scope only to a directory.
)
# All of the include directories are added to the include path of the target.