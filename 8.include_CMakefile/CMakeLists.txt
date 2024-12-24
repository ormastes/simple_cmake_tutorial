cmake_minimum_required(VERSION 3.10)
project(Private_Public_include_path)

# include utils file
include(utils.cmake)

# print HELLO_TO is World or not
print_is_world("Hello from Function")
message("MY_LOCAL_VAR outside function is: ${MY_LOCAL_VAR}")

# Preprocess predefine header file and append to every .cpp file
ADD_PREDEFINE_HEADERFILE("predefine_variables.h")
message("MY_LOCAL_VAR outside macro is: ${MY_LOCAL_VAR}")

# Add the subdirectory for the library
add_subdirectory(lib)

# Build an executable that depends on mylib
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE mylib)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)