# Simple CMake Tutorial

## Table of Contents
1. [Hello World (Executable Target)](#1-hello-world-executable-target)
2. [add_subdirectory (Library)](#2-add_subdirectory-library)
3. [CMake Script Along With Sources](#3-cmake-script-along-with-sources)
4. [Basic Control Flow if() / foreach() / while() / list()](#4-basic-control-flow-if--foreach--while--list)
5. [Variables and Predefines](#5-variables-and-predefines)
6. [Private/Public Include Path](#6-privatepublic-include-path)
7. [Function / Macro](#7-function--macro)
8. [Include File (.cmake)](#8-include-file-cmake)
9. [Variable Cache And Precedence](#9-variable-cache-and-precedence)

## 1. Hello World (Executable Target)

### Purpose
Learn how to create the simplest possible CMake project - a "Hello World" executable.

### Example Structure
```
hello_world/
├── CMakeLists.txt
└── main.cpp
```

### main.cpp
```cpp
#include <iostream>

int main() {
    std::cout << "Hello World!" << std::endl;
    return 0;
}
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)

# 1) Define project name
project(HelloWorldProject)

# 2) Create executable target named "hello_world"
add_executable(hello_world main.cpp)
```

### How to Build
1. Create and enter a build directory:
```bash
mkdir build
cd build
```

2. Generate build files:
```bash
cmake ..
```
This configures CMake using the parent directory's CMake script and generates platform-specific build files (Makefiles, Visual Studio solutions, etc.).

3. Build the project:
```bash
cmake --build .
```
This builds using the generated build files in the current directory.

4. Run the executable:
```bash
# Windows
.\Debug\hello_world.exe
```
```bash
# Linux
./hello_world
```

## 2. add_subdirectory (Library)

### Purpose
Learn how to structure a project that includes both a library and an executable. This example demonstrates using `add_subdirectory` to incorporate a library into your build.

### Example Structure
```
subdirectory_example/
├── main.cpp
├── CMakeLists.txt
└── lib/
    ├── CMakeLists.txt
    ├── mylib.h
    └── mylib.cpp
```

### lib/CMakeLists.txt
```cmake
# Build a static library named mylib
add_library(mylib STATIC mylib.cpp)

# Optionally, set include paths for this library
target_include_directories(mylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

### lib/mylib.cpp
```cpp
#include <iostream>

void print_mylib() {
    std::cout << "Hello World!" << std::endl;
}
```

*(A corresponding `mylib.h` would contain the function declarations)*

### Top-Level CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)
project(SubdirectoryExample)

# Add the subdirectory for the library
add_subdirectory(lib)

# Build an executable that depends on mylib
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE mylib)
```

### main.cpp
```cpp
// Forward-declare or include the header for print_mylib()
void print_mylib();

int main() {
    print_mylib();
    return 0;
}
```

## 3. CMake Script Along With Sources

### Purpose
Learn how to organize CMake build scripts alongside source code, managing both the current directory and its subdirectories.

### Example Structure
```
subdirectory_example/
├── main.cpp
├── CMakeLists.txt
└── lib/
    ├── mylib.h
    └── mylib.cpp
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)
project(CMake_Script_Along_With_Sources)

# Build an executable
add_executable(my_app main.cpp lib/mylib.cpp)

target_include_directories(my_app PRIVATE lib)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)
```

Note: The separate lib/CMakeLists.txt is not needed in this approach.

## 4. Basic Control Flow if() / foreach() / while() / list()

### Purpose
Learn how to implement logic and loops in CMake scripts for more dynamic build configurations.

### If-Else Examples
```cmake
set(HELLO_TO "World")
if(HELLO_TO STREQUAL "World")
    message("HELLO_TO is World")
else()
    message("HELLO_TO is NOT World")
endif()
```

Here's an example of setting compiler options based on the compiler type:
```cmake
# Include the header file in every .cpp file
if (MSVC)
    add_compile_options(/FI"${CMAKE_BINARY_DIR}/predefine_variables.h")
else()
    add_compile_options(-include "${CMAKE_BINARY_DIR}/predefine_variables.h")
endif()
```

### Loops
```cmake
# foreach()
set(NAMES "Alice" "Bob" "Charlie")
foreach(NAME IN LISTS NAMES)
    message("Name: ${NAME}")
endforeach()

# while()
set(COUNT 0)
while(COUNT LESS 3)
    message("Count is ${COUNT}")
    math(EXPR COUNT "${COUNT} + 1")
endwhile()
```

## 5. Variables and Predefines

### Purpose
Understand how to use CMake variables to store and manage build configuration information.

### Setting Variables
```cmake
set(MY_VAR "Hello")
```

### Using Variables
```cmake
message("The value of MY_VAR is: ${MY_VAR}")
```

### Types of Variables
- **Normal variables**: Exist only during CMake configuration. They are cleared between runs unless cached.
- **Cached variables**: Persist in `CMakeCache.txt` between CMake runs, allowing for persistent configuration settings.

## 6. Private/Public Include Path

### Purpose
Learn how to manage header visibility and include paths using PRIVATE, PUBLIC, and INTERFACE specifications.

### Example with Private Header Available to User
#### Structure 1
```
subdirectory_example/
├── main.cpp
├── CMakeLists.txt
└── lib/
    ├── CMakeLists.txt
    ├── private_std_short.h
    ├── mylib.h
    └── mylib.cpp
```

#### lib/private_std_short.h
```cpp
#pragma once
// Not a good idea
#define COUT std::cout
#define ENDL std::endl
```

#### lib/mylib.cpp
```cpp
#include "mylib.h"
#include "private_std_short.h"
#include <iostream>

void print_mylib() {
    COUT << "Hello " << HELLO_TO << "!" << ENDL;
}
```

#### Structure 2 (Improved Organization)
```
subdirectory_example/
├── CMakeLists.txt
├── main.cpp
└── lib/
    ├── CMakeLists.txt
    ├── private_std_short.h
    ├── mylib.cpp
    └── include/
        └── mylib.h
```

#### lib/CMakeLists.txt
```cmake
# Build a static library named mylib. Notice that interface header files are included in the library target.
add_library(mylib STATIC mylib.cpp include/mylib.h)

# Include path for PRIVATE and PUBLIC
target_include_directories(mylib 
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR} 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```
##### lib/include/mylib.h
no content changes, but just move from lib to lib/include

### Additional Notes
For a header-only library:
```cmake
add_library(my_header_only_lib INTERFACE)

# Specify the include directories for mylib
target_include_directories(my_header_only_lib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
```

## 7. Function / Macro

### Purpose
Master the creation of reusable CMake code using functions and macros. Understanding the difference between function scope (local) and macro scope (caller's scope) is crucial.

### Example Structure
```
subdirectory_example/
├── CMakeLists.txt
├── main.cpp
└── lib/
    ├── CMakeLists.txt
    ├── private_std_short.h
    ├── mylib.cpp
    └── include/
        └── mylib.h
```

### Function Example
```cmake
# print HELLO_TO is World or not
function(print_is_world MESSAGE)
    if(MESSAGE STREQUAL "World")
        message("MESSAGE is World")
    else()
        message("MESSAGE is NOT World")
    endif()
    # Variables set in a function are scoped locally by default
    set(MY_LOCAL_VAR "Inside function" PARENT_SCOPE)
endfunction()

print_is_world("Hello from Function")
message("MY_LOCAL_VAR outside function is: ${MY_LOCAL_VAR}")
```

### Macro Example
```cmake
# Preprocess predefine header file and append to every .cpp file
macro(ADD_PREDEFINE_HEADERFILE HEADER_FILE)
    # Build script variable to predefine
    configure_file(${HEADER_FILE}.in ${HEADER_FILE})
    # For smaller project, use target_compile_definitions or add_compile_definitions

    # Include the header file in every .cpp file
    if (MSVC)
        add_compile_options(/FI"${CMAKE_BINARY_DIR}/${HEADER_FILE}")
    else()
        add_compile_options(-include "${CMAKE_BINARY_DIR}/${HEADER_FILE}")
    endif()

    # Variables set in a macro affect the caller's scope
    set(MY_LOCAL_VAR "Inside macro")
endmacro()

ADD_PREDEFINE_HEADERFILE("predefine_variables.h")
message("MY_LOCAL_VAR outside macro is: ${MY_LOCAL_VAR}")
```

## 8. Include File (.cmake)

### Purpose
Learn how to organize CMake code by separating reusable components into separate .cmake files.

### Example Structure
```
subdirectory_example/
├── CMakeLists.txt
├── utils.cmake
├── main.cpp
└── lib/
    ├── CMakeLists.txt
    ├── private_std_short.h
    ├── mylib.cpp
    └── include/
        └── mylib.h
```

### utils.cmake
```cmake
# print HELLO_TO is World or not
function(print_is_world MESSAGE)
    # If statement to print a message
    if(MESSAGE STREQUAL "World")
        message("MESSAGE is World")
    else()
        message("MESSAGE is NOT World")
    endif()
    # Variables set in a function are scoped locally by default
    set(MY_LOCAL_VAR "Inside function" PARENT_SCOPE)
endfunction()

print_is_world("Hello from Function")
message("MY_LOCAL_VAR outside function is: ${MY_LOCAL_VAR}")

# Preprocess predefine header file and append to every .cpp file
macro(ADD_PREDEFINE_HEADERFILE HEADER_FILE)
    # Build script variable to predefine
    configure_file(${HEADER_FILE}.in ${HEADER_FILE})
    # For smaller project, use target_compile_definitions or add_compile_definitions

    # Include the header file in every .cpp file
    if (MSVC)
        add_compile_options(/FI"${CMAKE_BINARY_DIR}/${HEADER_FILE}")
    else()
        add_compile_options(-include "${CMAKE_BINARY_DIR}/${HEADER_FILE}")
    endif()

    # Variables set in a macro affect the caller's scope
    set(MY_LOCAL_VAR "Inside macro")
endmacro()
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)
project(IncludeFileExample)

# Include the custom .cmake file
include(my_settings.cmake)

add_executable(include_example main.cpp)

# Use the variable defined in my_settings.cmake
target_compile_definitions(include_example PRIVATE MY_CUSTOM_DEFINE="${MY_CUSTOM_DEFINE}")
```

### main.cpp
```cpp
#include <iostream>
#ifndef MY_CUSTOM_DEFINE
#define MY_CUSTOM_DEFINE "Not Defined"
#endif

int main() {
    std::cout << "MY_CUSTOM_DEFINE: " << MY_CUSTOM_DEFINE << std::endl;
    return 0;
}
```

## 9. Variable Cache And Precedence

### Purpose
Understand how CMake handles variables from different sources and their precedence order to effectively manage build configurations.

### Variable Types and Precedence
Variables affect the current scope and its children from where they are defined unless PARENT_SCOPE is used, which alters a parent variable.

- Command-line variables (-D) are defined before any CMake script is executed.
- Cache variables are set up using command-line variables if provided.
- Environment variables can only be accessed with $ENV{}.

### Example Structure
```
subdirectory_example/
├── CMakeLists.txt
├── main.cpp
└── lib/
    ├── CMakeLists.txt
    ├── private_std_short.h
    ├── mylib.cpp
    └── include/
        └── mylib.h
```

#### config.cmake
```cmake
set(HELLO_TO "From Include File")
message("config.cmake: HELLO_TO = ${HELLO_TO}")
```

#### CMakeLists.txt
```cmake
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
target_link_libraries(my_app PRIVATE mylib)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)
```

#### lib/CMakeLists.txt
```cmake
set(HELLO_TO "From subdirectory")
```

### Demonstrating Precedence

#### 1. Basic Build (No Options)
```bash
mkdir build && cd build
cmake ..
```
Output shows:
```
Env variable: HELLO_TO = 
Before include: HELLO_TO = 
    config.cmake: HELLO_TO = From Include File
After include: HELLO_TO = From Include File
After normal set: HELLO_TO = From CMakeLists
After cache set: HELLO_TO = From Cache
...
After add_subdirectory: HELLO_TO = From Cache
```

#### 2. With Environment Variable
```bash
# Linux/macOS
export HELLO_TO="From Environment"
# Windows
set HELLO_TO="From Environment"

cmake ..
```
Output shows:
```
Env variable: HELLO_TO = "From Environment"
Before include: HELLO_TO =
config.cmake: HELLO_TO = From Include Line
After include: HELLO_TO = From Include Line
After normal set: HELLO_TO = From CMakeLists
After cache set: HELLO_TO = From Cache
...
After add_subdirectory: HELLO_TO = From Cache
```

#### 3. With Command Line Variable (Highest Precedence)
```bash
cmake .. -DHELLO_TO="From Command Line"
```
Output shows:
```
Env variable: HELLO_TO = 
Before include: HELLO_TO = From Command Line
    config.cmake: HELLO_TO = From Include File
After include: HELLO_TO = From Include File
After normal set: HELLO_TO = From CMakeLists
After cache set: HELLO_TO = From Command Line
...
After add_subdirectory: HELLO_TO = From Command Line
```

### Key Points
1. **Command Line (-D) Variables**
   - Set initial variable.
   - Override cache variables.
   - Persist in cache until explicitly changed.

2. **Environment Variables**
   - Only accessed with '$ENV{}'.
   - Do not affect other variables.
   - Don't persist in cache.

3. **Cache Variables**
   - Persist between runs.
   - Command-line variables override cache values.
   - Can be viewed/edited in 'CMakeCache.txt'.

4. **Normal Variables**
   - Local to the current 'CMakeLists.txt' and its children.
   - Do not alter parent variables unless specified with 'PARENT_SCOPE'.

5. **Included File Variables**
   - Inclusion is equivalent to embedding.
   - Changes in the included file affect variables in the current 'CMakeLists.txt'.