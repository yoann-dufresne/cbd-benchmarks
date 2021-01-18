cmake_minimum_required(VERSION 3.16)
project(contains)
add_compile_options(-Wall -Wextra)      #basic compiler options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -mavx2 -Dlest_FEATURE_AUTO_REGISTER=1 -Dlest_FEATURE_COLOURISE=1 -O3 -DNDEBUG") #Compilation flag
set(SRCS
  contains.cpp
  #successors.cpp
  #contains_for_space.cpp
  #successors_for_space.cpp
  )
add_executable(contains ${SRCS})
add_subdirectory(ConwayBromageLib) #Where ConwayBromageLib contains CBl CMakeLists.txt 
target_link_libraries(contains cbl)    #the name of the CBl library is cbl
