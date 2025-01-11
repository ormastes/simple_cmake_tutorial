cmake_minimum_required(VERSION 3.10)
project(VariablesAndPredefinesExample)

# Add the subdirectory for the library
add_subdirectory(lib)

# Build an executable that depends on mylib
add_executable(my_app main.cpp)
target_link_libraries(my_app 
PRIVATE 
    mylib
)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)