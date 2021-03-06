INCLUDE_DIRECTORIES (${CMAKE_INSTALL_PREFIX}/include)

IF (NOT DEFINED TARGET_NAME)
	SET (TARGET_NAME "${PROJECT_NAME}")
ENDIF ()

GET_TARGET_PROPERTY (_TYPE ${TARGET_NAME} TYPE)
IF ("${_TYPE}" STREQUAL "INTERFACE_LIBRARY")
	TARGET_INCLUDE_DIRECTORIES (${TARGET_NAME}
		INTERFACE $<INSTALL_INTERFACE:include>)
ELSE ()
	LINK_DIRECTORIES (${CMAKE_BINARY_DIR})

	TARGET_INCLUDE_DIRECTORIES (${TARGET_NAME}
		PUBLIC
		$<INSTALL_INTERFACE:include>
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/src)

	FILE (GLOB _SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c*)
	STRING (TOLOWER ${CMAKE_SYSTEM_NAME} _SYSTEM_NAME)
	FILE (GLOB_RECURSE _PSOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/${_SYSTEM_NAME}/*.c*)
	TARGET_SOURCES (${TARGET_NAME} PRIVATE ${_SOURCES} ${_PSOURCES})
ENDIF ()

IF (NOT "${_TYPE}" STREQUAL "EXECUTABLE" AND NOT "${_TYPE}" MATCHES "INTERFACE*" AND NOT "${_TYPE}" MATCHES "MODULE*")
	INCLUDE (CMakePackageConfigHelpers)
	WRITE_BASIC_PACKAGE_VERSION_FILE (
		"${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake"
		COMPATIBILITY SameMajorVersion)

	GET_PROPERTY (PACKAGES GLOBAL PROPERTY PACKAGES_FOUND)
	FOREACH (PKG ${PACKAGES})
		SET (PROJECT_DEPENDENCIES "${PROJECT_DEPENDENCIES}FIND_DEPENDENCY (${PKG} REQUIRED)\n")
	ENDFOREACH ()
	CONFIGURE_FILE (
		"${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
		"${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}Config.cmake"
		@ONLY)
	UNSET (PROJECT_DEPENDENCIES)
	GET_PROPERTY (PARENT DIRECTORY PROPERTY PARENT_DIRECTORY)
	IF (NOT "${PARENT}" STREQUAL "")
		SET_PROPERTY (GLOBAL PROPERTY PACKAGES_FOUND "")
	ENDIF()

	INSTALL (FILES
		"${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}Config.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake"
		DESTINATION lib/cmake/${TARGET_NAME})

	IF (NOT DEFINED NAMESPACE)
		SET (NAMESPACE "${TARGET_NAME}")
	ENDIF()
	INSTALL (EXPORT ${TARGET_NAME}Targets
		FILE ${TARGET_NAME}Targets.cmake
		NAMESPACE ${NAMESPACE}::
		DESTINATION lib/cmake/${TARGET_NAME})
ENDIF()

INSTALL (TARGETS ${TARGET_NAME}
	EXPORT ${TARGET_NAME}Targets
	LIBRARY DESTINATION lib COMPONENT libraries
	ARCHIVE DESTINATION lib COMPONENT libraries
	RUNTIME DESTINATION bin COMPONENT runtime)

IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include)
	INSTALL (DIRECTORY include/
		DESTINATION include
		COMPONENT development)
ENDIF()

IF (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test")
	SET_PROPERTY (GLOBAL PROPERTY MAIN_TARGET ${TARGET_NAME})
	ADD_SUBDIRECTORY (test)
ENDIF()

IF (NOT "${CPACK_GENERATOR}" STREQUAL "")
	INCLUDE (CPack-config)
ENDIF()
