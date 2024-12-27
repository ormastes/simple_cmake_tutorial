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
가장 간단한 CMake 프로젝트인 "Hello World" 실행 파일을 만드는 방법을 배웁니다.

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
1. 빌드 디렉토리를 생성하고 진입합니다:
```bash
mkdir build
cd build
```

2. 빌드 파일을 생성합니다:
```bash
cmake ..
```
이는 상위 디렉토리의 CMake 스크립트를 사용하여 CMake를 구성하고 플랫폼별 빌드 파일(Makefiles, Visual Studio 솔루션 등)을 생성합니다.

3. 프로젝트를 빌드합니다:
```bash
cmake --build .
```
이는 현재 디렉토리의 생성된 빌드 파일을 사용하여 빌드합니다.

4. 실행 파일을 실행합니다:
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
라이브러리와 실행 파일을 모두 포함하는 프로젝트를 구성하는 방법을 배웁니다. 이 예제는 `add_subdirectory`를 사용하여 빌드에 라이브러리를 포함하는 방법을 보여줍니다.

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

*(해당하는 `mylib.h`는 함수 선언을 포함할 것입니다)*

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
현재 디렉토리와 하위 디렉토리를 모두 관리하면서 소스 코드와 함께 CMake 빌드 스크립트를 구성하는 방법을 배웁니다.

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

참고: 이 접근 방식에서는 별도의 lib/CMakeLists.txt가 필요하지 않습니다.

## 4. Basic Control Flow if() / foreach() / while() / list()

### Purpose
더 동적인 빌드 구성을 위해 CMake 스크립트에서 로직과 반복문을 구현하는 방법을 배웁니다.

### If-Else Examples
```cmake
set(HELLO_TO "World")
if(HELLO_TO STREQUAL "World")
    message("HELLO_TO is World")
else()
    message("HELLO_TO is NOT World")
endif()
```

다음은 컴파일러 유형에 따라 컴파일러 옵션을 설정하는 예시입니다:
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
빌드 구성 정보를 저장하고 관리하기 위해 CMake 변수를 사용하는 방법을 이해합니다.

### Setting Variables
```cmake
set(MY_VAR "Hello")
```

### Using Variables
```cmake
message("The value of MY_VAR is: ${MY_VAR}")
```

### Types of Variables
- **일반 변수**: CMake 구성 중에만 존재합니다. 캐시되지 않는 한 실행 간에 지워집니다.
- **캐시 변수**: CMake 실행 간에 `CMakeCache.txt`에 유지되어 지속적인 구성 설정을 가능하게 합니다.

## 6. Private/Public Include Path

### Purpose
PRIVATE, PUBLIC 및 INTERFACE 지정을 사용하여 헤더 가시성과 include 경로를 관리하는 방법을 배웁니다.

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

#### Structure 2 (향상된 구조)
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
내용은 변경되지 않고, lib에서 lib/include로 이동만 합니다.

### Additional Notes
헤더 전용 라이브러리의 경우:
```cmake
add_library(my_header_only_lib INTERFACE)

# Specify the include directories for mylib
target_include_directories(my_header_only_lib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
```

## 7. Function / Macro

### Purpose
함수와 매크로를 사용하여 재사용 가능한 CMake 코드를 작성하는 방법을 숙달합니다. 함수 스코프(로컬)와 매크로 스코프(호출자의 스코프)의 차이를 이해하는 것이 중요합니다.

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
재사용 가능한 컴포넌트를 별도의 .cmake 파일로 분리하여 CMake 코드를 구성하는 방법을 배웁니다.

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
다양한 소스의 변수들과 그들의 우선순위 순서를 CMake가 어떻게 처리하는지 이해하여 빌드 구성을 효과적으로 관리합니다.

주의: 단순 List에 값추가가 아니면 같은 변수 이름으로 Overwrite하지 않는다. 즉 Precedence를 고려할 필요가 없도록 한다.

### Variable Types and Precedence
변수는 PARENT_SCOPE를 사용하여 상위 변수를 변경하지 않는 한, 정의된 현재 범위와 그 하위 범위에 영향을 미칩니다.

- 명령줄 변수(-D)는 모든 CMake 스크립트가 실행되기 전에 정의됩니다.
- 캐시 변수는 제공된 경우 명령줄 변수를 사용하여 설정됩니다.
- 환경 변수는 $ENV{}를 통해서만 접근할 수 있습니다.

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

### 우선순위 시연

#### 1. 기본 빌드 (옵션 없음)
```bash
mkdir build && cd build
cmake ..
```
출력 결과:
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

#### 2. 환경 변수 사용
```bash
# Linux/macOS
export HELLO_TO="From Environment"
# Windows
set HELLO_TO="From Environment"

cmake ..
```
출력 결과:
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

#### 3. 명령줄 변수 사용 (최고 우선순위)
```bash
cmake .. -DHELLO_TO="From Command Line"
```
출력 결과:
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

### 주요 포인트
1. **명령줄 (-D) 변수**
   - 초기 변수를 설정합니다.
   - 캐시 변수를 재정의합니다.
   - 명시적으로 변경될 때까지 캐시에 유지됩니다.

2. **환경 변수**
   - '$ENV{}'로만 접근 가능합니다.
   - 다른 변수에 영향을 주지 않습니다.
   - 캐시에 유지되지 않습니다.

3. **캐시 변수**
   - 실행 사이에 유지됩니다.
   - 명령줄 변수가 캐시 값을 재정의합니다.
   - 'CMakeCache.txt'에서 확인/편집할 수 있습니다.

4. **일반 변수**
   - 현재 'CMakeLists.txt'와 그 하위에서만 유효합니다.
   - 'PARENT_SCOPE'로 지정하지 않는 한 상위 변수를 변경하지 않습니다.

5. **포함된 파일 변수**
   - 포함은 임베딩과 동일합니다.
   - 포함된 파일의 변경사항이 현재 'CMakeLists.txt'의 변수에 영향을 미칩니다.
