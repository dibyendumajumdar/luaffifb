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

option(USE_LUA53 "Controls whether the library will be for Lua 5.3 or Ravi, default is OFF" OFF)

set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake" )

find_package(Lua REQUIRED)

message(STATUS "LUA_INCLUDE_DIR: ${LUA_INCLUDE_DIR}")
message(STATUS "LUA_LIBRARIES  : ${LUA_LIBRARIES}")

set( DASM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dynasm )

# Dynasm
set ( DASM ${DASM_DIR}/dynasm.lua )

if ( APPLE )
	list ( APPEND LIBS m )
	add_definitions( -DLUA_USE_MACOSX )
elseif ( NOT WIN32 )
	list ( APPEND LIBS m )
	add_definitions( -DLUA_USE_LINUX )
endif ()

if (MSVC)
	add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
	add_definitions(-DLUA_FFI_BUILD_AS_DLL)
	add_definitions(-D_CRT_STDIO_INLINE=__declspec\(dllexport\)__inline)
endif()

if (MSVC)
    set(CMAKE_C_FLAGS_DEBUG "/Od /D_DEBUG /MDd /Zi /RTC1 /EHsc")
    set(CMAKE_C_FLAGS_RELEASE "/DNDEBUG /O2 /MD /EHsc")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "/DNDEBUG /O2 /MD /Zi /EHsc")
    set(CMAKE_C_FLAGS_MINSIZEREL "/DNDEBUG /O2 /MD /EHsc")

    set(CMAKE_CXX_FLAGS "/EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "/Od /D_DEBUG /MDd /Zi /RTC1 /EHsc")
    set(CMAKE_CXX_FLAGS_RELEASE "/DNDEBUG /O2 /MD /EHsc")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/DNDEBUG /O2 /MD /Zi /EHsc")
    set(CMAKE_CXX_FLAGS_MINSIZEREL "/DNDEBUG /O2 /MD /EHsc")

    # Disable signed/unsigned int conversion warnings.
    add_definitions("/wd4018")
    # Disable warning about using struct/class for the same symobl.
    add_definitions("/wd4099")
    # Disable performance warning about int-to-bool conversion.
    add_definitions("/wd4800")
    # Disable signed/unsigned int conversion warnings.
    add_definitions("/wd4018")
    # Disable warning about the insecurity of using "std::copy".
    add_definitions("/wd4996")
    add_definitions("/wd4291")
    add_definitions("/wd4624")
    add_definitions("/wd4141")
    add_definitions("/DLUA_COMPAT_5_2")
    add_definitions("/DLUA_COMPAT_5_1")
endif ()

# Build minilua
add_executable ( minilua minilua.c )
target_link_libraries ( minilua ${LIBS} )

include_directories( ${LUA_INCLUDE_DIR} )
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
if (APPLE)
	set_target_properties(ffi PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

add_library(libtest SHARED 
		test.c)
if (MSVC)
	set_source_files_properties(test.c PROPERTIES COMPILE_FLAGS /Gd)
endif()
target_link_libraries(libtest ffi) 
set_target_properties(libtest PROPERTIES PREFIX "")
if (APPLE)
	set_target_properties(libtest PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

install(TARGETS ffi
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
		LIBRARY DESTINATION lib)

install(TARGETS libtest
        RUNTIME DESTINATION bin/ffi
        LIBRARY DESTINATION lib/ffi)

install(TARGETS minilua
        RUNTIME DESTINATION bin)

INSTALL(FILES "test.lua" DESTINATION "${LUADIR}/ffi")
