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
가장 간단한 CMake 프로젝트인 "Hello World" 실행 파일을 만드는 방법을 배웁니다.

CMake는 고수준 빌드 스크립트 언어입니다. 다른 고수준 프로그래밍 언어와 유사하게, 사용하기 전에 프로그래밍 언어의 컴파일 단계와 비슷한 설정(Configuration) 단계가 필요합니다. 이 단계는 환경과 캐시 변수를 설정하기 때문에 "Configure" 또는 "Cache Configuration step"라고 불립니다. 설정(configuration) 과정에서 CMake는 빌드 스크립트 실행 파일, 도구, 라이브러리의 일반적인 위치를 자동으로 검색합니다. 이러한 위치는 수동으로도 설정할 수 있습니다.
Make, Ninja, MSBuild와 같은 저수준 빌드 시스템은 직접 사용하거나 CMake를 통해 최종 바이너리를 생성하는 데 사용될 수 있습니다.
(개인적으로 별다른 이유가 없으면 Module을 많이 습니다.)

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

CMake는 CMakeLists.txt 파일을 포함하는 디렉토리를 모듈로 처리할 수 있습니다. 각 모듈은 사용자를 위한 공용 include 경로나 다른 필요한 속성들을 선언할 수 있으며, target_link_libraries()를 사용하는 것만으로도 타겟 사용자의 include 경로와 속성 설정을 자동화할 수 있습니다.

더 자세히 설명하면:
- 각 모듈(라이브러리)은 자신만의 CMakeLists.txt를 가질 수 있습니다
- 모듈은 PUBLIC으로 include 경로를 선언하여 사용자에게 자동으로 전파할 수 있습니다
- target_link_libraries()를 사용하면 라이브러리의 모든 PUBLIC 설정이 자동으로 전파됩니다
- 이를 통해 라이브러리 사용자는 별도의 include 경로 설정 없이도 라이브러리를 사용할 수 있습니다
예시:
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

target_link_libraries(my_app 
PRIVATE 
    mylib
)

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

Subdirectory target에서 단하나의 PRIVATE 디랙토리 ${CMAKE_CURRENT_SOURCE_DIR}와 PRIVATE 디랙토리를 포함하지 않는 ${CMAKE_CURRENT_SOURCE_DIR}/include 과 같은 PUBLIC 디랙토리 하나만을 가지도록 하는 것이 보다 좋은 디자인이 될 수 있다다.
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
다음은 이상적인 include 경로 설정을 나타냅니다. Root와 Public 경로에 없는 다른 헤더 파일들을 include하여야 하는 경우 모듈의 루트로부터의 경로를 사용하여 include 되어야 합니다.

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

특별한 이유가 있지 않는 이상 function을 사용하는 것이 macro를 사용하는 것보다 좋습니다. 종종  macro에서 caller의 variable을 update하는 것이 쉬우며 이런 상황은 macro사용이 정당화 될 수 있는 상황입니다.

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


## 부록 1. Subdirectory를 무엇이라 부를까?
CMake에서 프로젝트의 서브디렉토리는 일반적으로 전체 프로젝트 내에서의 역할이나 구조에 따라 지칭됩니다. 엄격한 통일된 용어는 없지만, 다음과 같은 용어들이 일반적으로 사용됩니다:
(개인적으로 특별한 의미가 없을 땐 Module이란 말을 많이 씁씁니다.)
---

### **1. 모듈(Module)**
   - **사용**: 서브디렉토리는 프로젝트의 논리적으로 독립된 부분을 나타내는 경우 흔히 "모듈"이라고 불립니다. 주로 재사용하거나 독립적으로 연결할 수 있는 기능을 캡슐화합니다.
   - **특징**:
     - 자체 `CMakeLists.txt`를 포함하는 경우가 많음
     - 라이브러리(`STATIC`, `SHARED`, 또는 `OBJECT`)로 빌드됨
     - 프로젝트의 다른 부분에서 의존성으로 사용됨
   - 예시:
     ```
     src/
       core/
         CMakeLists.txt  # 'core' 모듈 정의
       utils/
         CMakeLists.txt  # 'utils' 모듈 정의
     ```

---

### **2. 패키지(Package)**
   - **사용**: 더 큰 규모나 다중 프로젝트 설정에서 더 일반적이며, 서브디렉토리는 함께 배포되는 독립형 라이브러리, 실행 파일 또는 리소스 모음을 제공하는 경우 "패키지"로 지칭될 수 있습니다.
   - **특징**:
     - 여러 라이브러리나 실행 파일을 포함할 수 있음
     - `CMake`를 통해 설치 가능한 컴포넌트를 만들 때 자주 사용됨
   - 예시:
     ```
     packages/
       logging/
         CMakeLists.txt  # 'logging' 패키지 정의
       network/
         CMakeLists.txt  # 'network' 패키지 정의
     ```

---

### **3. 컴포넌트(Component)**
   - **사용**: "모듈"과 때때로 호환되어 사용되지만, 선택적 기능이나 서브모듈이 있는 프로젝트에 더 특화되어 있습니다.
   - **특징**:
     - CMake 옵션(`-DBUILD_COMPONENT_X=ON`)과 if() 문을 통해 활성화하거나 비활성화할 수 있는 프로젝트의 선택적 부분을 나타낼 때 "컴포넌트"라고 부릅니다.
   - 예시:
     ```
     components/
       CMakeLists.txt # UI 컴포넌트
       gui/
         CMakeLists.txt  # GUI 컴포넌트
       cli/
         CMakeLists.txt  # CLI 컴포넌트
     ```
     ```cmake
    # components/CMakeLists.txt
    option(BUILD_COMPONENT_X "X 컴포넌트 빌드" ON) # 보통 루트 CMakeLists.txt에 위치
    # 루트 CMakeLists.txt에서
    if (BUILD_COMPONENT_X)
        add_subdirectory(components/X)
    endif()
    ```

---

### **4. 서브프로젝트(Subproject)**
   - **사용**: 서브디렉토리가 자체 완전한 빌드 시스템을 가지고 있고 더 큰 프로젝트 내에서 독립적인 단위로 취급되는 경우 "서브프로젝트"로 지칭됩니다.
   - **특징**:
     - 루트에 자체 `CMakeLists.txt`를 포함
     - 독립적으로 빌드되거나 `add_subdirectory()`를 통해 포함될 수 있음
   - 예시:
     ```
     projects/
       mylib/
         CMakeLists.txt  # 독립적인 서브프로젝트
       myapp/
         CMakeLists.txt  # 또 다른 독립적인 서브프로젝트
     ```

---

### **5. 라이브러리(Library)**
   - **사용**: 서브디렉토리의 주요 역할이 라이브러리를 정의하고 빌드하는 것이라면, 흔히 그냥 "라이브러리"라고 부릅니다.
   - **특징**:
     - 일반적으로 `STATIC` 또는 `SHARED` 라이브러리로 빌드됨
     - 프로젝트의 다른 부분에서 `target_link_libraries()`를 통해 사용됨
   - 예시:
     ```
     libs/
       math/
         CMakeLists.txt  # 수학 라이브러리
       graphics/
         CMakeLists.txt  # 그래픽스 라이브러리
     ```

---

### **어떤 용어를 사용할까요?**
- **"모듈" 사용**: 서브디렉토리가 프로젝트의 논리적 부분을 나타내는 경우 (내부 프로젝트에서 일반적)
- **"패키지" 사용**: 서브디렉토리가 독립형 컴포넌트로 배포되거나 설치되는 경우
- **"컴포넌트" 사용**: 서브디렉토리를 선택적으로 포함/제외할 수 있는 경우
- **"서브프로젝트" 사용**: 서브디렉토리가 독립적이며 별도로 빌드될 수 있는 경우
- **"라이브러리" 사용**: 서브디렉토리가 주로 라이브러리를 만드는 것이 목적인 경우

구체적인 용어는 종종 프로젝트의 구성, 팀의 선호도 또는 프로젝트의 도메인에 따라 달라집니다.