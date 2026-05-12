########## MACROS ###########################################################################
#############################################################################################

# Requires CMake > 3.15
if(${CMAKE_VERSION} VERSION_LESS "3.15")
    message(FATAL_ERROR "The 'CMakeDeps' generator only works with CMake >= 3.15")
endif()

if(civetweb_FIND_QUIETLY)
    set(civetweb_MESSAGE_MODE VERBOSE)
else()
    set(civetweb_MESSAGE_MODE STATUS)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cmakedeps_macros.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/civetwebTargets.cmake)
include(CMakeFindDependencyMacro)

check_build_type_defined()

foreach(_DEPENDENCY ${civetweb_FIND_DEPENDENCY_NAMES} )
    # Check that we have not already called a find_package with the transitive dependency
    if(NOT ${_DEPENDENCY}_FOUND)
        find_dependency(${_DEPENDENCY} REQUIRED ${${_DEPENDENCY}_FIND_MODE})
    endif()
endforeach()

set(civetweb_VERSION_STRING "1.16")
set(civetweb_INCLUDE_DIRS ${civetweb_INCLUDE_DIRS_RELEASE} )
set(civetweb_INCLUDE_DIR ${civetweb_INCLUDE_DIRS_RELEASE} )
set(civetweb_LIBRARIES ${civetweb_LIBRARIES_RELEASE} )
set(civetweb_DEFINITIONS ${civetweb_DEFINITIONS_RELEASE} )


# Definition of extra CMake variables from cmake_extra_variables


# Only the last installed configuration BUILD_MODULES are included to avoid the collision
foreach(_BUILD_MODULE ${civetweb_BUILD_MODULES_PATHS_RELEASE} )
    message(${civetweb_MESSAGE_MODE} "Conan: Including build module from '${_BUILD_MODULE}'")
    include(${_BUILD_MODULE})
endforeach()


