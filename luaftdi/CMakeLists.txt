PROJECT("org.muhkuh.lua-luaftdi")
SET(PROJECT_VERSION  "1.0.0")

FIND_PACKAGE(SWIG REQUIRED)

# Get the VCS version for the jonchki configuration.
INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/version.cmake)

# Filter the jonchki configuration.
CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/luaftdi.xml
               ${CMAKE_CURRENT_BINARY_DIR}/luaftdi-${PROJECT_VERSION}.xml
               @ONLY)

#----------------------------------------------------------------------------
#
# Build the project.
#

IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
	INCLUDE(${SWIG_USE_FILE})

	# Add a custom target for the swig runtime for LUA.
	INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/muhkuh_swig_lua_runtime.cmake)

	# Select the LUA version.
	INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/muhkuh_lua.cmake)

	INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
	INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/../external/libftdi/libftdi1-1.3/src/TARGET_libftdi1/src)

	SET_SOURCE_FILES_PROPERTIES(ftdi1.i PROPERTIES CPLUSPLUS OFF)
	SET_SOURCE_FILES_PROPERTIES(ftdi1.i PROPERTIES SWIG_FLAGS "")
	SWIG_ADD_MODULE(TARGET_luaftdi lua ftdi1.i)
	SWIG_LINK_LIBRARIES(TARGET_luaftdi ${LUA_LIBRARIES})

	# Set the name of the output file to "luaftdi".
	SET_TARGET_PROPERTIES(TARGET_luaftdi PROPERTIES PREFIX "" OUTPUT_NAME "luaftdi")

	# On mingw link all compiler libraries static.
	IF((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") AND (${CMAKE_COMPILER_IS_GNUCC}))
		set_property(TARGET TARGET_luaftdi PROPERTY LINK_FLAGS "-static-libgcc -static-libstdc++")
	ENDIF((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") AND (${CMAKE_COMPILER_IS_GNUCC}))


	# Install the lua module.
	INSTALL(TARGETS TARGET_luaftdi DESTINATION ${INSTALL_DIR_LUA_MODULES})


	# Add tests for this module.
	IF((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") AND (${CMAKE_COMPILER_IS_GNUCC}))
		# Here are the MinGW specific tests.
		ADD_TEST(NAME luaftdi_MinGW_DLL_dependencies
		         COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tests/mingw_dll_dependencies.py -u lua5.1 -u lua5.2 -u lua5.3 $<TARGET_FILE:TARGET_luaftdi>)
	ENDIF((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") AND (${CMAKE_COMPILER_IS_GNUCC}))

	# Write a version file.
	FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/install/org.muhkuh.lua-luaftdi.version "SET(org.muhkuh.lua-luaftdi_VERSION ${PROJECT_VERSION})")
	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/org.muhkuh.lua-luaftdi.version DESTINATION ".")
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
