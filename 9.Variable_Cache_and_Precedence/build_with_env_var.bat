rem Linux/macOS
rem export HELLO_TO="From Environment"
rem Windows
set HELLO_TO="From Environment"

mkdir build_with_env_var 
cd build_with_env_var
cmake .. 
cmake --build .
.\Debug\my_app.exe
cd ..

rem expected
rem Env variable: HELLO_TO = "From Environment"
rem Before include: HELLO_TO =
rem config.cmake: HELLO_TO = From Include Line
rem After include: HELLO_TO = From Include Line
rem After normal set: HELLO_TO = From CMakeLists
rem After cache set: HELLO_TO = From Cache
rem ...
rem After add_subdirectory: HELLO_TO = From Cache

