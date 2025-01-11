cmake_minimum_required(VERSION 3.10)
project(CMake_Script_Along_With_Sources)

# Build an executable
add_executable(my_app main.cpp lib/mylib.cpp)

target_link_libraries(my_app 
PRIVATE 
    mylib
)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)