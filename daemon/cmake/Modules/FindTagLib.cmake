# - find TagLib
# Once done, this will define
#
#  TAGLIB_FOUND        - system has TagLib
#  TAGLIB_INCLUDE_DIRS - the TagLib include directories
#  TAGLIB_LIBRARIES    - link these to use TagLib

if(NOT TAGLIB_FOUND)
	message(STATUS "Looking for TagLib")
	find_program(TAGLIB_CONFIG_EXECUTABLE NAMES taglib-config)

	if(TAGLIB_CONFIG_EXECUTABLE)
		exec_program(${TAGLIB_CONFIG_EXECUTABLE} ARGS --version OUTPUT_VARIABLE TAGLIB_VERSION)
		if(TAGLIB_VERSION)
			message(STATUS "Found TagLib version ${TAGLIB_VERSION}")
			exec_program(${TAGLIB_CONFIG_EXECUTABLE} ARGS --cflags OUTPUT_VARIABLE TAGLIB_INCLUDE_DIRS)
			if(TAGLIB_INCLUDE_DIRS)
				string(REPLACE "-I" "" TAGLIB_INCLUDE_DIRS "${TAGLIB_INCLUDE_DIRS}")
			else(TAGLIB_INCLUDE_DIRS)
				message(SEND_ERROR "Could not set TagLib include directories")
			endif(TAGLIB_INCLUDE_DIRS)
			exec_program(${TAGLIB_CONFIG_EXECUTABLE} ARGS --libs OUTPUT_VARIABLE TAGLIB_LIBRARIES)
			if(NOT TAGLIB_LIBRARIES)
				message(SEND_ERROR "Could not set TagLib libraries")
			endif(NOT TAGLIB_LIBRARIES)
			set(TAGLIB_FOUND TRUE)
		else(TAGLIB_VERSION)
			message(SEND_ERROR "Could not determine version of TagLib")
		endif(TAGLIB_VERSION)	
	else(TAGLIB_CONFIG_EXECUTABLE)
		message(SEND_ERROR "Could not find taglib-config")
	endif(TAGLIB_CONFIG_EXECUTABLE)
endif(NOT TAGLIB_FOUND)
