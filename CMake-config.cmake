INCLUDE_DIRECTORIES (${CMAKE_INSTALL_PREFIX}/include)

GET_TARGET_PROPERTY (_TYPE ${PROJECT_NAME} TYPE)
IF ("${_TYPE}" STREQUAL "INTERFACE_LIBRARY")
	TARGET_INCLUDE_DIRECTORIES (${PROJECT_NAME}
		INTERFACE $<INSTALL_INTERFACE:include>)
ELSE ()
	LINK_DIRECTORIES (${CMAKE_BINARY_DIR})

	TARGET_INCLUDE_DIRECTORIES (${PROJECT_NAME}
		PUBLIC
		$<INSTALL_INTERFACE:include>
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/src)

	AUX_SOURCE_DIRECTORY (${CMAKE_CURRENT_SOURCE_DIR}/src _SOURCES)
	TARGET_SOURCES (${PROJECT_NAME} PRIVATE ${_SOURCES})
ENDIF ()

IF (NOT "${_TYPE}" STREQUAL "EXECUTABLE" AND NOT "${_TYPE}" MATCHES "INTERFACE*" AND NOT "${_TYPE}" MATCHES "MODULE*")
	INCLUDE (CMakePackageConfigHelpers)
	WRITE_BASIC_PACKAGE_VERSION_FILE (
		"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
		COMPATIBILITY SameMajorVersion)

	GET_PROPERTY (PACKAGES GLOBAL PROPERTY PACKAGES_FOUND)
	FOREACH (PKG ${PACKAGES})
		SET (PROJECT_DEPENDENCIES "${PROJECT_DEPENDENCIES}FIND_DEPENDENCY (${PKG} REQUIRED)\n")
	ENDFOREACH ()
	CONFIGURE_FILE (
		"${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
		"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
		@ONLY)
	UNSET (PROJECT_DEPENDENCIES)

	INSTALL (FILES
		"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
		DESTINATION lib/cmake/${PROJECT_NAME})

	IF (NOT DEFINED NAMESPACE)
		SET (NAMESPACE "${PROJECT_NAME}")
	ENDIF()
	SET (TOUCHING ${NAMESPACE}) # Suprime mensagem de warning para variável não utilizada
	INSTALL (EXPORT ${PROJECT_NAME}Targets
		FILE ${PROJECT_NAME}Targets.cmake
		NAMESPACE ${NAMESPACE}::
		DESTINATION lib/cmake/${PROJECT_NAME})
	UNSET (NAMESPACE)
ENDIF()

INSTALL (TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}Targets
	LIBRARY DESTINATION lib COMPONENT libraries
	ARCHIVE DESTINATION lib COMPONENT libraries
	RUNTIME DESTINATION bin COMPONENT runtime)

IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include)
	INSTALL (DIRECTORY include/
		DESTINATION include
		COMPONENT development)
ENDIF()

FILE (COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeGraphVizOptions.cmake
	DESTINATION ${CMAKE_BINARY_DIR})

IF (BUILD_TESTS AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test")
	ADD_SUBDIRECTORY (test)
ENDIF ()

IF (NOT "${CPACK_GENERATOR}" STREQUAL "")
	INCLUDE (CPack-config)
ENDIF()

# Para projetos sendo construídos como subdiretórios a variável global
# deve ser limpa a cada novo projeto.
SET_PROPERTY (GLOBAL PROPERTY PACKAGES_FOUND "")
