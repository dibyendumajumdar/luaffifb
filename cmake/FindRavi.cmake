find_path(LUA_INCLUDE_DIR lua.h
  PATHS
  c:/Software/ravi/include/ravi
  ~/ravi/include/ravi
  NO_DEFAULT_PATH
)

find_library(LUA_LIBRARY
  NAMES ravi libravi libravinojit
  PATHS
  c:/Software/ravi/lib
  ~/ravi/lib
)

set( LUA_INCLUDE_DIRS "${LUA_INCLUDE_DIR}" )
set( LUA_LIBRARIES "${LUA_LIBRARY}" )