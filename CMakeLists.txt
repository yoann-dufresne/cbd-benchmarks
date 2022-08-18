cmake_minimum_required(VERSION 3.19)
project(ConwayBromageDatastructureBenchmark)
add_compile_options(-Wall -Wextra)      #basic compiler options

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -std=c++17 -DNDEBUG  -pthread") #Compilation flag


add_subdirectory(cbd)