cmake_minimum_required(VERSION 2.8)
project(blang)

add_compile_options(-std=c++1z -m64 -fexceptions -Wpedantic -W -Wall -Werror)

add_subdirectory(src)
