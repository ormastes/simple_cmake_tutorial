cmake_minimum_required(VERSION 3.10)
project(CMake_Script_Along_With_Sources)

# Build an executable
add_executable(my_app main.cpp lib/mylib.cpp)

target_include_directories(my_app PRIVATE lib)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)