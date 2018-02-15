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

endif()

if (NOT WIN32)
  set( LUA_LIBRARIES "${LUA_LIBRARY};m")
endif()
