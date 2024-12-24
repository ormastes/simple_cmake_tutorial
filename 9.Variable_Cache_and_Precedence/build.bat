mkdir build 
cd build
cmake .. 
cmake --build .
.\Debug\my_app.exe
cd ..

rem expected
rem Env variable: HELLO_TO = 
rem Before include: HELLO_TO = 
rem     config.cmake: HELLO_TO = From Include File
rem After include: HELLO_TO = From Include File
rem After normal set: HELLO_TO = From CMakeLists
rem After cache set: HELLO_TO = From Cache
rem ...
rem After add_subdirectory: HELLO_TO = From Cache
