CMAKE_MINIMUM_REQUIRED(VERSION 3.7)

PROJECT("org.muhkuh.lua-lua5.1-luaftdi-artifact")

INCLUDE(../../../cmake/version.cmake)

SET(INSTALL_WINDOWS_X86        "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/windows_x86")
SET(INSTALL_WINDOWS_X86_64     "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/windows_x86_64")
SET(INSTALL_UBUNTU_1404_X86    "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1404_x86")
SET(INSTALL_UBUNTU_1404_X86_64 "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1404_x86_64")
SET(INSTALL_UBUNTU_1604_X86    "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1604_x86")
SET(INSTALL_UBUNTU_1604_X86_64 "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1604_x86_64")
SET(INSTALL_UBUNTU_1704_X86    "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1704_x86")
SET(INSTALL_UBUNTU_1704_X86_64 "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1704_x86_64")
SET(INSTALL_UBUNTU_1710_X86    "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1710_x86")
SET(INSTALL_UBUNTU_1710_X86_64 "${CMAKE_CURRENT_SOURCE_DIR}/../../../build/lua5.1/ubuntu_1710_x86_64")

# Get the project version. Both the WIN32 and the WIN64 folder have the same version file.
INCLUDE(${INSTALL_WINDOWS_X86}/org.muhkuh.lua-luaftdi.version)
SET(PROJECT_VERSION ${org.muhkuh.lua-luaftdi_VERSION})

SET(CPACK_OUTPUT_FILE_PREFIX ../jonchki/repository/org/muhkuh/lua/luaftdi/${PROJECT_VERSION})
SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
SET(CPACK_PACKAGE_FILE_NAME "lua5.1-luaftdi-${PROJECT_VERSION}")

SET(CPACK_GENERATOR "TXZ")
INCLUDE(CPack)


#-----------------------------------------------------------------------------
#
# Install the 32bit files.
#
INSTALL(FILES ${INSTALL_WINDOWS_X86}/lua_plugins/luaftdi.dll
        DESTINATION windows_x86/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1404_X86}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1404_x86/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1604_X86}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1604_x86/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1704_X86}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1704_x86/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1710_X86}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1710_x86/lua_plugins)


#-----------------------------------------------------------------------------
#
# Install the 64bit files.
#
INSTALL(FILES ${INSTALL_WINDOWS_X86_64}/lua_plugins/luaftdi.dll
        DESTINATION windows_x86_64/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1404_X86_64}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1404_x86_64/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1604_X86_64}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1604_x86_64/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1704_X86_64}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1704_x86_64/lua_plugins)

INSTALL(FILES ${INSTALL_UBUNTU_1710_X86_64}/lua_plugins/luaftdi.so
        DESTINATION ubuntu_1710_x86_64/lua_plugins)


#-----------------------------------------------------------------------------

INSTALL(FILES install.lua
        DESTINATION .)

CONFIGURE_FILE(luaftdi.xml
               ${CPACK_OUTPUT_FILE_PREFIX}/lua5.1-luaftdi-${PROJECT_VERSION}.xml
               @ONLY)


#-----------------------------------------------------------------------------
#
# Filter the pom.xml file.
#
SET(POM_ARTIFACT_ID  "lua5.1-luaftdi")
SET(POM_GROUP_ID     "org.muhkuh.lua")
SET(POM_VERSION      "${PROJECT_VERSION}")
SET(POM_PACKAGING    "tar.xz")
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/pom.xml ${CPACK_OUTPUT_FILE_PREFIX}/lua5.1-luaftdi-${PROJECT_VERSION}.pom)
