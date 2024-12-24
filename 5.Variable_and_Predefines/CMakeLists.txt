cmake_minimum_required(VERSION 3.10)
project(VariablesAndPredefinesExample)

# Set a build script variable
set(HELLO_TO "World")

# If statement to print a message
if(HELLO_TO STREQUAL "World")
    message("HELLO_TO is World")
else()
    message("HELLO_TO is NOT World")
endif()

# Build script variable to predefine
configure_file(predefine_variables.h.in predefine_variables.h)
# For smaller project, use target_compile_definitions or add_compile_definitions

# Include the header file in every .cpp file
if (MSVC)
    add_compile_options(/FI"${CMAKE_BINARY_DIR}/predefine_variables.h")
else()
    add_compile_options(-include "${CMAKE_BINARY_DIR}/predefine_variables.h")
endif()

# Add the subdirectory for the library
add_subdirectory(lib)

# Build an executable that depends on mylib
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE mylib)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)