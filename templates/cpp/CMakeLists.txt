cmake_minimum_required(VERSION 3.24)

project(cpp_template LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---------------------------------------
# Library
# ---------------------------------------
add_library(cpp_template_lib
    src/app.cpp
)

target_include_directories(cpp_template_lib
    PUBLIC include
)

# Optional: warnings
include(cmake/CompilerWarnings.cmake)
set_project_warnings(cpp_template_lib)

# ---------------------------------------
# Executable
# ---------------------------------------
add_executable(cpp-template
    src/main.cpp
)

target_link_libraries(cpp-template
    PRIVATE cpp_template_lib
)

# ---------------------------------------
# Tests (optional but recommended)
# ---------------------------------------
# enable_testing()
#
# add_executable(test_main
#     tests/test_main.cpp
# )
#
# target_link_libraries(test_main
#     PRIVATE cpp_template_lib
# )
#
# add_test(NAME unit_tests COMMAND test_main)
