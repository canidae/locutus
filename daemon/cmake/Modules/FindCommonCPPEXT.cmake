# Find CommonCPPEXT include directories & libraries.
# Once done, this will define:
# - COMMONCPPEXT_FOUND
# - COMMONCPPEXT_INCLUDE_DIR
# - COMMONCPPEXT_LIBRARIES

find_path(COMMONCPPEXT_INCLUDE_DIR NAMES common.h PATHS
	/usr/include/cc++/
	/usr/local/include/cc++/
)

find_library(COMMONCPPEXT_LIBRARIES NAMES ccext2)

if(COMMONCPPEXT_INCLUDE_DIR AND COMMONCPPEXT_LIBRARIES)
	set(COMMONCPPEXT_FOUND TRUE)
	if(NOT CommonCPPEXT_FIND_QUIETLY)
		message(STATUS "Found CommonCPPEXT: ${COMMONCPPEXT_INCLUDE_DIR}, ${COMMONCPPEXT_LIBRARIES}")
	endif()
else()
	if(CommonCPPEXT_FIND_REQUIRED)
		message(FATAL_ERROR "Could not find CommonCPPEXT")
	else()
		if(NOT CommonCPPEXT_FIND_QUIETLY)
			message(STATUS "Could not find CommonCPPEXT")
		endif()
	endif()
endif()
