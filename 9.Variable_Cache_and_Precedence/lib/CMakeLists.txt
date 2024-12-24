# Build a static library named mylib. Notice that interface header files are included in the library target.
add_library(mylib STATIC mylib.cpp include/mylib.h)

# Include path for PRIAVATE and PUBLIC
target_include_directories(mylib 
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR} 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set(HELLO_TO "From subdirectory")
message(STATUS "Hello from subdirectory: ${HELLO_TO}")