# Find TagLib include directories & libraries.
# Once done, this will define:
# - TAGLIB_FOUND
# - TAGLIB_INCLUDE_DIR
# - TAGLIB_LIBRARIES

find_path(TAGLIB_INCLUDE_DIR NAMES taglib.h PATHS
	/usr/include/taglib/
	/usr/local/include/taglib/
)

find_library(TAGLIB_LIBRARIES NAMES tag)

if(TAGLIB_INCLUDE_DIR AND TAGLIB_LIBRARIES)
	set(TAGLIB_FOUND TRUE)
	if(NOT TagLib_FIND_QUIETLY)
		message(STATUS "Found TagLib: ${TAGLIB_INCLUDE_DIR}, ${TAGLIB_LIBRARIES}")
	endif()
else()
	if(TagLib_FIND_REQUIRED)
		message(FATAL_ERROR "Could not find TagLib")
	else()
		if(NOT TagLib_FIND_QUIETLY)
			message(STATUS "Could not find TagLib")
		endif()
	endif()
endif()
