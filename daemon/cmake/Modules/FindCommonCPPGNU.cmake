# Find CommonCPPGNU include directories & libraries.
# Once done, this will define:
# - COMMONCPPGNU_FOUND
# - COMMONCPPGNU_INCLUDE_DIR
# - COMMONCPPGNU_LIBRARIES

find_path(COMMONCPPGNU_INCLUDE_DIR NAMES common.h PATHS
	/usr/include/cc++/
	/usr/local/include/cc++/
)

find_library(COMMONCPPGNU_LIBRARIES NAMES ccgnu2)

if(COMMONCPPGNU_INCLUDE_DIR AND COMMONCPPGNU_LIBRARIES)
	set(COMMONCPPGNU_FOUND TRUE)
	if(NOT CommonCPPGNU_FIND_QUIETLY)
		message(STATUS "Found CommonCPPGNU: ${COMMONCPPGNU_INCLUDE_DIR}, ${COMMONCPPGNU_LIBRARIES}")
	endif()
else()
	if(CommonCPPGNU_FIND_REQUIRED)
		message(FATAL_ERROR "Could not find CommonCPPGNU")
	else()
		if(NOT CommonCPPGNU_FIND_QUIETLY)
			message(STATUS "Could not find CommonCPPGNU")
		endif()
	endif()
endif()
