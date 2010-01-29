cmake_minimum_required(VERSION 2.6)
project(LOCUTUS)

if(CMAKE_BUILD_TYPE STREQUAL "")
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None, Debug or Release." FORCE)
endif()
set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -s")

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")

find_package(TagLib REQUIRED)
find_package(CommonCPPGNU REQUIRED)
find_package(CommonCPPEXT REQUIRED)
find_package(SQLite)
find_package(PostgreSQL)

if(NOT SQLITE_FOUND AND NOT POSTGRESQL_FOUND)
	message(FATAL_ERROR "Need header files & libraries for at least one database system")
endif()

include_directories(
	${LOCUTUS_SOURCE_DIR}/include
	${TAGLIB_INCLUDE_DIR}
)

set(HEADER_FILES
	include/Album.h
	include/Artist.h
	include/Audioscrobbler.h
	include/Comparison.h
	include/Config.h
	include/Database.h
	include/Debug.h
	include/FileNamer.h
	include/Levenshtein.h
	include/Locutus.h
	include/Matcher.h
	include/Metafile.h
	include/Metatrack.h
	include/MusicBrainz.h
	include/Track.h
	include/WebService.h
)

set(SOURCE_FILES
	src/Album.cpp
	src/Artist.cpp
	src/Audioscrobbler.cpp
	src/Comparison.cpp
	src/Config.cpp
	src/Debug.cpp
	src/FileNamer.cpp
	src/Levenshtein.cpp
	src/Locutus.cpp
	src/Matcher.cpp
	src/Metafile.cpp
	src/Metatrack.cpp
	src/MusicBrainz.cpp
	src/Track.cpp
	src/WebService.cpp
)

set(LIBRARIES
	${TAGLIB_LIBRARIES}
	${COMMONCPPGNU_LIBRARIES}
	${COMMONCPPEXT_LIBRARIES}
)

if(SQLITE_FOUND)
	add_definitions("-DSQLITE_ENABLED")
	set(HEADER_FILES ${HEADER_FILES} include/SQLite.h)
	set(SOURCE_FILES ${SOURCE_FILES} src/SQLite.cpp)
	set(LIBRARIES ${LIBRARIES} ${SQLITE_LIBRARIES})
endif()
if(POSTGRESQL_FOUND)
	add_definitions("-DPOSTGRESQL_ENABLED")
	set(HEADER_FILES ${HEADER_FILES} include/PostgreSQL.h)
	set(SOURCE_FILES ${SOURCE_FILES} src/PostgreSQL.cpp)
	set(LIBRARIES ${LIBRARIES} ${POSTGRESQL_LIBRARIES})
endif()

add_executable(locutus ${HEADER_FILES} ${SOURCE_FILES})
target_link_libraries(locutus ${LIBRARIES})
