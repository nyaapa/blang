cmake_minimum_required(VERSION 2.8)
project(blang)

add_compile_options(-std=c++1z -m64 -fexceptions -Wpedantic -W -Wall -Werror -g)

add_subdirectory(src)

enable_testing()

file(
    GLOB_RECURSE
    TEST_FILES
    t/*.pl
)
FOREACH(TEST_FILE ${TEST_FILES})
    STRING(REGEX REPLACE "^.*/([^/]+)\\.pl" "\\1" TEST_NAME ${TEST_FILE})
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_FILE} --binary-dir ${PROJECT_BINARY_DIR})
ENDFOREACH()

set(CMAKE_CTEST_COMMAND ctest -V)
add_custom_target(check ${CMAKE_CTEST_COMMAND} DEPENDS blangc)
