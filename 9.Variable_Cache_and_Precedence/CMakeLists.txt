cmake_minimum_required(VERSION 3.10)
project(VariablePrecedenceExample)

# 0. Start of variable
message("Env variable: HELLO_TO = $ENV{HELLO_TO}")
message("Before include: HELLO_TO = ${HELLO_TO}")

# 1. First, include external cmake file (lowest precedence)
include(config.cmake)
message("After include: HELLO_TO = ${HELLO_TO}")

# 2. Set normal variable (overrides included file)
set(HELLO_TO "From CMakeLists")
message("After normal set: HELLO_TO = ${HELLO_TO}")

# 3. Set cache variable (overrides normal variable)
set(HELLO_TO "From Cache" CACHE STRING "Who to say hello to")
message("After cache set: HELLO_TO = ${HELLO_TO}")

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

# 4. after add_subdirectory (does not affect variables in the parent scope unless PARENT_SCOPE is used)
message("After add_subdirectory: HELLO_TO = ${HELLO_TO}")

# Build an executable that depends on mylib
add_executable(my_app main.cpp)
target_link_libraries(my_app 
PRIVATE 
    mylib
)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)