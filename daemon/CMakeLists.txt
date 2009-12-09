cmake_minimum_required(VERSION 2.6)
project(LOCUTUS)

if (CMAKE_BUILD_TYPE STREQUAL "")
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build, options are: None, Debug or Release." FORCE)
endif ()
set(CMAKE_CXX_FLAGS "-Wall -Wextra -pedantic")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
set(CMAKE_CXX_FLAGS_RELEASE "-Os")

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")

find_package(TagLib)

include_directories("${TAGLIB_INCLUDE_DIRS}")
include_directories("${LOCUTUS_SOURCE_DIR}/include")

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
	include/PostgreSQL.h
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
	src/PostgreSQL.cpp
	src/Track.cpp
	src/WebService.cpp
)

add_executable(locutus ${HEADER_FILES} ${SOURCE_FILES})
target_link_libraries(locutus ${TAGLIB_LIBRARIES})
