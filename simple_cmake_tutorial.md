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

[Appendix 1. How call subdirectory](#appendix-1-how-call-subdirectory)

## 1. Hello World (Executable Target)

### Purpose
Learn how to create the simplest possible CMake project - a "Hello World" executable.

CMake is a high-level build script language. Similarly to other high-level programming languages, it requires a configuration step before use, which is analogous to the compilation step in programming languages. This step is called "Configure" or "Cache Configuration step" because it sets up the environment and cache variables. During configuration, CMake automatically searches well-known locations for build script executables, tools, and libraries. These locations can also be set manually.
Low-level build systems such as Make, Ninja, or MSBuild can be used either directly or through CMake to generate the final binary.
(Personally, I use Module often when it does not have specific context.)

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

# Define project name
project(HelloWorldProject)

# Create executable target named "hello_world"
add_executable(hello_world main.cpp)

# Make build VERBOSE
set(CMAKE_VERBOSE_MAKEFILE ON)
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

CMake can handle modules as directories containing a CMakeLists.txt file. Each module can declare its public include path or other required properties for its user, automating the target user's include path and property settings by just using target_link_libraries().

To explain in more detail:
- Each module (library) can have its own CMakeLists.txt
- Modules can declare include paths as PUBLIC to automatically propagate to users
- Using target_link_libraries() automatically propagates all PUBLIC settings from the library
- This allows library users to use the library without manual include path settings
Example:
```cmake
# lib/CMakeLists.txt
add_library(mylib STATIC mylib.cpp)
target_include_directories(mylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```
```cmake
# Toplevel CMakeLists.txt
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE mylib)  # mylib의 include 경로가 자동으로 my_app에 전파됨
```

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
```

### lib/mylib.cpp
```cpp
#include <iostream>

void print_mylib() {
    std::cout << "Hello World!" << std::endl;
}
```

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

target_link_libraries(my_app 
PRIVATE 
    mylib
)

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

In subdirecotry target, It is better to include only one PRIVATE directory which point ${CMAKE_CURRENT_SOURCE_DIR} and one PUBLIC directory which not include PRIVATE directory such as ${CMAKE_CURRENT_SOURCE_DIR}/include.
Example:
```cmake
target_include_directories(myTarget
PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
PUBLIC  
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

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
This represent ideal include path setting. When other header files which is not on Root and Public path should included, it should be included with path from the root of the module.

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

Unless there is specific reason, it is better to use function over macro. Often caller variable updates can be easily implementedin macro rather than function and it is the situation where the macro usage can be justified.

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


## Appendix 1. How call subdirectory
In CMake, subdirectories in a project are typically referred to based on their role or how they are structured within the overall project. While there is no strict universal terminology, the following terms are commonly used:

---

### **1. Module**
   - **Usage**: A subdirectory is often called a "module" if it represents a logically self-contained part of the project, typically encapsulating functionality that can be reused or linked independently.
   - **Characteristics**:
     - Often contains its own `CMakeLists.txt`.
     - Builds into a library (`STATIC`, `SHARED`, or `OBJECT`).
     - Used by other parts of the project as a dependency.
   - Example:
     ```
     src/
       core/
         CMakeLists.txt  # Defines the 'core' module
       utils/
         CMakeLists.txt  # Defines the 'utils' module
     ```

---

### **2. Package**
   - **Usage**: More common in larger or multi-project setups, a subdirectory may be referred to as a "package" if it provides a standalone collection of libraries, executables, or resources that are distributed together.
   - **Characteristics**:
     - May include multiple libraries or executables.
     - Often used when creating installable components via `CMake`.
   - Example:
     ```
     packages/
       logging/
         CMakeLists.txt  # Defines the 'logging' package
       network/
         CMakeLists.txt  # Defines the 'network' package
     ```

---

### **3. Component**
   - **Usage**: Sometimes used interchangeably with "module," but more specific to projects with optional features or submodules.
   - **Characteristics**:
     - A subdirectory is called a "component" when it represents an optional part of the project, potentially enabled or disabled via CMake options (`-DBUILD_COMPONENT_X=ON`) with if() statement.
   - Example:
     ```
     components/
       CMakeLists.txt # UI component
       gui/
         CMakeLists.txt  # GUI component
       cli/
         CMakeLists.txt  # CLI component
     ```
     ```cmake
    # components/CMakeLists.txt
    option(BUILD_COMPONENT_X "Build the X component" ON) // usually on root CMakeLists.txt
    # In the root CMakeLists.txt
    if (BUILD_COMPONENT_X)
        add_subdirectory(components/X)
    endif()
    ```
---

### **4. Subproject**
   - **Usage**: A subdirectory is often referred to as a "subproject" if it has its own complete build system and is treated as an independent unit within a larger project.
   - **Characteristics**:
     - Contains its own `CMakeLists.txt` at the root.
     - Can often be built independently or included via `add_subdirectory()`.
   - Example:
     ```
     projects/
       mylib/
         CMakeLists.txt  # Independent subproject
       myapp/
         CMakeLists.txt  # Another independent subproject
     ```

---

### **5. Library**
   - **Usage**: If a subdirectory's primary role is to define and build a library, it's often just called a "library."
   - **Characteristics**:
     - Typically builds into a `STATIC` or `SHARED` library.
     - Used via `target_link_libraries()` by other parts of the project.
   - Example:
     ```
     libs/
       math/
         CMakeLists.txt  # Math library
       graphics/
         CMakeLists.txt  # Graphics library
     ```

---

### **Which Term to Use?**
- **Use "module"**: If the subdirectory represents a logical part of the project (common in internal projects).
- **Use "package"**: If the subdirectory is distributed or installed as a standalone component.
- **Use "component"**: If the subdirectory can be optionally included/excluded.
- **Use "subproject"**: If the subdirectory is independent and could be built separately.
- **Use "library"**: If the subdirectory is primarily for creating a library.

The specific terminology often depends on the project's organization, team preferences, or the project's domain.