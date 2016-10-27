#by Marinos Koutsomichalis, Heraklion 2015

cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project("neural_net")

#add project read_volume_pot

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -Wall -std=c++14")
set (SOURCES       src/main.cpp
		   )
include_directories(  /usr/local/include
  /usr/include
  /opt/local/include
		      ) 
link_directories(     /usr/local/lib
  /usr/lib
  /lib
  /opt/local/lib
  )

set(CMAKE_INSTALL_PREFIX  "${CMAKE_BINARY_DIR}/Install")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Install")

#user configuration
if(${CMAKE_BUILD_TYPE} MATCHES Debug)
  message("-- DEBUG MODE ON")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -DDEBUG")
else()
  message("-- RELEASE MODE ON")
  set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -O3")
endif()


#  app
add_executable(neural_net ${SOURCES} )
target_link_libraries(neural_net fann)

