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

    # Variables set in a macro affect the caller’s scope
    set(MY_LOCAL_VAR "Inside macro")
endmacro()