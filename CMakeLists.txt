## Copyright 2017 Matthias Stübinger
#
# This file is part of the Valaweb.
#
# This program is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see http://www.gnu.org/licenses/.
#
###

project (valaweb)

    cmake_minimum_required (VERSION 2.6)
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)


    set (EXEC_NAME "valaweb")
    set (RELEASE_NAME "the valaweb literate programming tool")
    set (VERSION "0.1")
    set (VERSION_INFO "Just a few first tests …")


    set (WEB_SOURCE "src/")

    IF (EXISTS ${CMAKE_BINARY_DIR}/${EXEC_NAME})
        set (TANGLER ${CMAKE_BINARY_DIR}/${EXEC_NAME})
    ELSE (EXISTS ${CMAKE_BINARY_DIR}/${EXEC_NAME})
        set (TANGLER ${CMAKE_BINARY_DIR}/bootstrap)
    ENDIF (EXISTS ${CMAKE_BINARY_DIR}/${EXEC_NAME})

     # copy the gresource directory into the build path
    add_custom_command (OUTPUT build_dir
                        COMMAND cp -r ${CMAKE_SOURCE_DIR}/${WEB_SOURCE} ${CMAKE_BINARY_DIR}
    )
    
    add_custom_command (OUTPUT ${CMAKE_BINARY_DIR}/bootstrap
                        DEPENDS build_dir
                        COMMAND valac --pkg gee-0.8 --pkg posix --pkg gio-2.0 ${CMAKE_BINARY_DIR}/src/bootstrap.vala -o bootstrap
    )
    
    
    add_custom_command (OUTPUT ${CMAKE_BINARY_DIR}/src/valaweb.vala
                        DEPENDS ${TANGLER}
                        DEPENDS build_dir
                        COMMENT ${TANGLER}
                        COMMAND ${TANGLER} ${CMAKE_BINARY_DIR}/src/valaweb.web
    )
    
                      
    # we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
    find_package(PkgConfig)

    # now let's actually check for the required dependencies
    pkg_check_modules(DEPS REQUIRED 
        gee-0.8
        gio-2.0
    )


    add_definitions(${DEPS_CFLAGS})
    link_libraries(${DEPS_LIBRARIES})
    link_directories(${DEPS_LIBRARY_DIRS})


    # make sure we have vala
    find_package(Vala REQUIRED)
    # make sure we use vala
    include(ValaVersion)
    # make sure it's the desired version of vala
    ensure_vala_version("0.16" MINIMUM)

    include(ValaPrecompile)
    vala_precompile(VALA_C ${EXEC_NAME}
        ${CMAKE_BINARY_DIR}/src/valaweb.vala
        
    PACKAGES
        gee-0.8
        gio-2.0
        posix
    )
    
    add_executable(${EXEC_NAME} ${VALA_C})

