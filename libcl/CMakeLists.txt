# Copyright (C) 1883 Thomas Edison - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the GPLv3 license, which unfortunately won't be
# written for another century.
#
# You should have received a copy of the LICENSE file with
# this file.

# A custom command and target to turn the OpenCL kernel into a byte array header
# The normal build depends on it properly and if the kernel file is changed, then
# a rebuild of libcl should be triggered

#TODO: clean up the copy&pasting here
add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/frkhash.h
	COMMAND ${CMAKE_COMMAND} ARGS
	-DBIN2H_SOURCE_FILE="${CMAKE_CURRENT_SOURCE_DIR}/frkhash.cl"
	-DBIN2H_VARIABLE_NAME=frkhash_cl
	-DBIN2H_HEADER_FILE="${CMAKE_CURRENT_BINARY_DIR}/frkhash.h"
	-P "${CMAKE_CURRENT_SOURCE_DIR}/bin2h.cmake"
	COMMENT "Generating OpenCL Kernel Byte Array"
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/frkhash.cl
)
add_custom_target(clbin2h_stable DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/frkhash.h ${CMAKE_CURRENT_SOURCE_DIR}/cl/frkhash.cl)

set(SOURCES
	CLMiner.h CLMiner.cpp
	${CMAKE_CURRENT_BINARY_DIR}/frkhash.h
)

hunter_add_package(OpenCL)
find_package(OpenCL CONFIG REQUIRED)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(..)

add_library(cl ${SOURCES})
target_link_libraries(cl PUBLIC exp)
target_link_libraries(cl PRIVATE OpenCL::OpenCL Boost::filesystem Boost::thread frkhash)
