if (USE_LUA53)

  find_path(LUA_INCLUDE_DIR lua.h
    PATHS
    c:/Software/lua53/include
    ~/lua53/include
    NO_DEFAULT_PATH
  )

  find_library(LUA_LIBRARIES
    NAMES lua53 liblua53
    PATHS
    c:/Software/lua53/lib
    ~/lua53/lib
  )

  find_program(LUA_EXE
    NAMES lua
    PATHS
    c:/Software/lua53/bin
    ~/lua53/bin
  )

else()

  find_path(LUA_INCLUDE_DIR lua.h
    PATHS
    c:/Software/ravi/include/ravi
    ~/ravi/include/ravi
    NO_DEFAULT_PATH
  )

  find_library(LUA_LIBRARIES
    NAMES ravi libravi ravinojit libravinojit ravillvm libravillvm
    PATHS
    c:/Software/ravi/lib
    ~/ravi/lib
  )

  find_program(LUA_EXE
    NAMES ravi_s
    PATHS
    c:/Software/ravi/bin
    ~/ravi/bin
  )

endif()

# LUA_INCDIR - place where lua headers exist
set(LUA_INCDIR ${LUA_INCLUDE_DIR})

# LIBDIR - LUA_CPATH
if (WIN32)

  get_filename_component(LIBDIR
    ${LUA_EXE}
    DIRECTORY)

else()

  get_filename_component(LIBDIR
    ${LUA_LIBRARIES}
    DIRECTORY)

endif()

get_filename_component(LUA_BINDIR
  ${LUA_EXE}
  DIRECTORY)

# LUA_LIBDIR - place where lua native libraries exist
get_filename_component(LUA_LIBDIR
  ${LUA_LIBRARIES}
  DIRECTORY
)

if (NOT WIN32) 
  set(LUA_LIBRARIES "${LUA_LIBRARIES};m")
endif()

# LUALIB - the lua library to link against
set(LUALIB ${LUA_LIBRARIES})

# LUADIR - LUA_PATH
if (USE_LUA53)
  set(LUADIR "${LUA_LIBDIR}/../share/lua/5.3")
else()
  set(LUADIR "${LUA_LIBDIR}/../share/lua/5.3")
endif()

set(LUA "${LUA_EXE}")

