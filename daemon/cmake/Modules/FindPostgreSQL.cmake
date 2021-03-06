# Find PostgreSQL include directories & libraries.
# Once done, this will define:
# - POSTGRESQL_FOUND
# - POSTGRESQL_INCLUDE_DIR
# - POSTGRESQL_LIBRARIES

find_path(POSTGRESQL_INCLUDE_DIR NAMES libpq-fe.h PATHS
	/usr/include/postgresql/
	/usr/local/include/postgresql/
)

find_library(POSTGRESQL_LIBRARIES NAMES pq)

if(POSTGRESQL_INCLUDE_DIR AND POSTGRESQL_LIBRARIES)
	set(POSTGRESQL_FOUND TRUE)
	if(NOT PostgreSQL_FIND_QUIETLY)
		message(STATUS "Found PostgreSQL: ${POSTGRESQL_INCLUDE_DIR}, ${POSTGRESQL_LIBRARIES}")
	endif()
else()
	if(PostgreSQL_FIND_REQUIRED)
		message(FATAL_ERROR "Could not find PostgreSQL")
	else()
		if(NOT PostgreSQL_FIND_QUIETLY)
			message(STATUS "Could not find PostgreSQL")
		endif()
	endif()
endif()
