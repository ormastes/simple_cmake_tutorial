cmake_minimum_required(VERSION 3.10)

# Define project name
project(HelloWorldProject)

# Create executable target named "hello_world"
add_executable(hello_world main.cpp)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)