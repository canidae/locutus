# Find SQLite include directories & libraries.
# Once done, this will define:
# - SQLITE_FOUND
# - SQLITE_INCLUDE_DIR
# - SQLITE_LIBRARIES

find_path(SQLITE_INCLUDE_DIR NAMES sqlite3.h PATHS
	/usr/include/
	/usr/local/include/
)

find_library(SQLITE_LIBRARIES NAMES sqlite3)

if(SQLITE_INCLUDE_DIR AND SQLITE_LIBRARIES)
	set(SQLITE_FOUND TRUE)
	if(NOT SQLite_FIND_QUIETLY)
		message(STATUS "Found SQLite: ${SQLITE_INCLUDE_DIR}, ${SQLITE_LIBRARIES}")
	endif(NOT SQLite_FIND_QUIETLY)
else(SQLITE_INCLUDE_DIR AND SQLITE_LIBRARIES)
	if(SQLite_FIND_REQUIRED)
		message(FATAL_ERROR "Could not find SQLite")
	else(SQLite_FIND_REQUIRED)
		if(NOT SQLite_FIND_QUIETLY)
			message(STATUS "Could not find SQLite")
		endif(NOT SQLite_FIND_QUIETLY)
	endif(SQLite_FIND_REQUIRED)
endif(SQLITE_INCLUDE_DIR AND SQLITE_LIBRARIES)
