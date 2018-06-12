SET (TNAME ${PROJECT_NAME}Library)

# Carrega todos os arquivos do diretório src em SOURCE
FILE (GLOB SOURCES "${CMAKE_SOURCE_DIR}/src/*.c*")

ADD_LIBRARY (${TNAME} "${SOURCES}")

SET_TARGET_PROPERTIES (${TNAME} PROPERTIES
	OUTPUT_NAME ${PROJECT_NAME}
	VERSION ${VERSION_FULL}
	SOVERSION ${VERSION_SHORT})

TARGET_INCLUDE_DIRECTORIES (${TNAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:include>
	PRIVATE
		src)

TARGET_LINK_LIBRARIES (${TNAME} ${EXTERNAL_LIBS})

INCLUDE (CMakePackageConfigHelper)
WRITE_BASIC_PACKAGE_VERSION_FILE (

)

INSTALL (
	TARGETS ${TNAME}
	EXPORT ${PROJECT_NAME}Config
	LIBRARY DESTINATION lib COMPONENT libraries
	ARCHIVE DESTINATION lib COMPONENT libraries)

INSTALL (
	EXPORT ${PROJECT_NAME}Config
	FILE "${PROJECT_NAME}Config.cmake"
	COMPONENT libraries
	DESTINATION lib/cmake)

UNSET (TNAME)
