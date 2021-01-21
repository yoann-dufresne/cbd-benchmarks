cmake_minimum_required(VERSION 3.16)
project(contains)
add_compile_options(-Wall -Wextra)      #basic compiler options

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -mavx2 -Dlest_FEATURE_AUTO_REGISTER=1 -Dlest_FEATURE_COLOURISE=1 -Ofast -DNDEBUG") #Compilation flag

# set(SRCS
#   contains.cpp
#   #successors.cpp
#   #contains_for_space.cpp
#   #successors_for_space.cpp
#   )
add_executable(contains contains.cpp)
add_executable(successors successors.cpp)
add_executable(contains_for_space contains_for_space.cpp)
add_executable(successors_for_space successors_for_space.cpp)

add_subdirectory(ConwayBromageLib) #Where ConwayBromageLib contains CBl CMakeLists.txt 

target_link_libraries(contains cbl)    #the name of the CBl library is cbl
target_link_libraries(successors cbl)    #the name of the CBl library is cbl
target_link_libraries(contains_for_space cbl)    #the name of the CBl library is cbl
target_link_libraries(successors_for_space cbl)    #the name of the CBl library is cbl
