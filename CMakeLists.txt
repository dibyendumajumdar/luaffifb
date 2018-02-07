# CMake script for building ravi-ffi
# Copyright (C) 2018 Dibyendu Majumdar
#
# Contains material from LuaDist project
# Copyright (C) 2012 LuaDist.
# Created by Peter Drahoš
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( ravi-ffi C )
cmake_minimum_required ( VERSION 2.8 )

set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake" )

find_package(Ravi REQUIRED)

set( DASM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dynasm )

# Dynasm
set ( DASM ${DASM_DIR}/dynasm.lua )

if ( APPLE )
	list ( APPEND LIBS m )
	add_definitions( -DLUA_USE_MACOSX )
elseif ( NOT WIN32 )
	list ( APPEND LIBS m )
endif ()

if (MSVC)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-DLUA_FFI_BUILD_AS_DLL)
endif()

# Build minilua
add_executable ( minilua minilua.c )
target_link_libraries ( minilua ${LIBS} )

include_directories( ${LUA_INCLUDE_DIRS} )
include_directories( ${DASM_DIR} )

if (CMAKE_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
	add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/call_x86.h
		COMMAND minilua ${DASM} -LN -D X32WIN -o ${CMAKE_SOURCE_DIR}/call_x86.h ${CMAKE_SOURCE_DIR}/call_x86.dasc
		DEPENDS minilua ${CMAKE_SOURCE_DIR}/call_x86.dasc
	)
	add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/call_x64.h
		COMMAND minilua ${DASM} -LN -D X64 -o ${CMAKE_SOURCE_DIR}/call_x64.h ${CMAKE_SOURCE_DIR}/call_x86.dasc
		DEPENDS minilua ${CMAKE_SOURCE_DIR}/call_x86.dasc
	)
	add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/call_x64win.h
		COMMAND minilua ${DASM} -LN -D X64 -D X64WIN -o ${CMAKE_SOURCE_DIR}/call_x64win.h ${CMAKE_SOURCE_DIR}/call_x86.dasc
		DEPENDS minilua ${CMAKE_SOURCE_DIR}/call_x86.dasc
	)
	set (CALL_HEADERS
		${CMAKE_SOURCE_DIR}/call_x86.h
		${CMAKE_SOURCE_DIR}/call_x64.h
		${CMAKE_SOURCE_DIR}/call_x64win.h
	)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
	add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/call_arm.h
		COMMAND minilua ${DASM} -LN -o ${CMAKE_SOURCE_DIR}/call_arm.h ${CMAKE_SOURCE_DIR}/call_arm.dasc
		DEPENDS minilua ${CMAKE_SOURCE_DIR}/call_arm.dasc
	)
	set (CALL_HEADERS
		${CMAKE_SOURCE_DIR}/call_arm.h
	)
else()
	# message()
endif()

set (HEADERS
	${CALL_HEADERS}
	ffi.h)

set (SRCS
	call.c 
	ctype.c 
	ffi.c 
	parser.c)

add_library(ffi SHARED 
	${HEADERS}
	${SRCS} )
target_link_libraries(ffi ${LUA_LIBRARIES}) 
set_target_properties(ffi PROPERTIES PREFIX "")

add_library(libtest SHARED 
		test.c)
if (MSVC)
	set_source_files_properties(test.c PROPERTIES COMPILE_FLAGS /Gd)
endif()
target_link_libraries(libtest ffi) 
set_target_properties(libtest PROPERTIES PREFIX "")

install(TARGETS ffi
        RUNTIME DESTINATION bin/ravi
        ARCHIVE DESTINATION lib
		LIBRARY DESTINATION lib/ravi)

install(TARGETS libtest
        RUNTIME DESTINATION bin/ravi/ffi
        LIBRARY DESTINATION lib/ravi/ffi)
