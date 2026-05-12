########## MACROS ###########################################################################
#############################################################################################

# Requires CMake > 3.15
if(${CMAKE_VERSION} VERSION_LESS "3.15")
    message(FATAL_ERROR "The 'CMakeDeps' generator only works with CMake >= 3.15")
endif()

if(prometheus-cpp_FIND_QUIETLY)
    set(prometheus-cpp_MESSAGE_MODE VERBOSE)
else()
    set(prometheus-cpp_MESSAGE_MODE STATUS)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cmakedeps_macros.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/prometheus-cppTargets.cmake)
include(CMakeFindDependencyMacro)

check_build_type_defined()

foreach(_DEPENDENCY ${prometheus-cpp_FIND_DEPENDENCY_NAMES} )
    # Check that we have not already called a find_package with the transitive dependency
    if(NOT ${_DEPENDENCY}_FOUND)
        find_dependency(${_DEPENDENCY} REQUIRED ${${_DEPENDENCY}_FIND_MODE})
    endif()
endforeach()

set(prometheus-cpp_VERSION_STRING "1.2.4")
set(prometheus-cpp_INCLUDE_DIRS ${prometheus-cpp_INCLUDE_DIRS_RELEASE} )
set(prometheus-cpp_INCLUDE_DIR ${prometheus-cpp_INCLUDE_DIRS_RELEASE} )
set(prometheus-cpp_LIBRARIES ${prometheus-cpp_LIBRARIES_RELEASE} )
set(prometheus-cpp_DEFINITIONS ${prometheus-cpp_DEFINITIONS_RELEASE} )


# Definition of extra CMake variables from cmake_extra_variables


# Only the last installed configuration BUILD_MODULES are included to avoid the collision
foreach(_BUILD_MODULE ${prometheus-cpp_BUILD_MODULES_PATHS_RELEASE} )
    message(${prometheus-cpp_MESSAGE_MODE} "Conan: Including build module from '${_BUILD_MODULE}'")
    include(${_BUILD_MODULE})
endforeach()


