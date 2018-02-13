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

if (NOT WIN32)
  set( LUA_LIBRARIES "${LUA_LIBRARY};m")
endif()
