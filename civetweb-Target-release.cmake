# Avoid multiple calls to find_package to append duplicated properties to the targets
include_guard()########### VARIABLES #######################################################################
#############################################################################################
set(civetweb_FRAMEWORKS_FOUND_RELEASE "") # Will be filled later
conan_find_apple_frameworks(civetweb_FRAMEWORKS_FOUND_RELEASE "${civetweb_FRAMEWORKS_RELEASE}" "${civetweb_FRAMEWORK_DIRS_RELEASE}")

set(civetweb_LIBRARIES_TARGETS "") # Will be filled later


######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
if(NOT TARGET civetweb_DEPS_TARGET)
    add_library(civetweb_DEPS_TARGET INTERFACE IMPORTED)
endif()

set_property(TARGET civetweb_DEPS_TARGET
             APPEND PROPERTY INTERFACE_LINK_LIBRARIES
             $<$<CONFIG:Release>:${civetweb_FRAMEWORKS_FOUND_RELEASE}>
             $<$<CONFIG:Release>:${civetweb_SYSTEM_LIBS_RELEASE}>
             $<$<CONFIG:Release>:openssl::openssl;civetweb::civetweb>)

####### Find the libraries declared in cpp_info.libs, create an IMPORTED target for each one and link the
####### civetweb_DEPS_TARGET to all of them
conan_package_library_targets("${civetweb_LIBS_RELEASE}"    # libraries
                              "${civetweb_LIB_DIRS_RELEASE}" # package_libdir
                              "${civetweb_BIN_DIRS_RELEASE}" # package_bindir
                              "${civetweb_LIBRARY_TYPE_RELEASE}"
                              "${civetweb_IS_HOST_WINDOWS_RELEASE}"
                              civetweb_DEPS_TARGET
                              civetweb_LIBRARIES_TARGETS  # out_libraries_targets
                              "_RELEASE"
                              "civetweb"    # package_name
                              "${civetweb_NO_SONAME_MODE_RELEASE}")  # soname

# FIXME: What is the result of this for multi-config? All configs adding themselves to path?
set(CMAKE_MODULE_PATH ${civetweb_BUILD_DIRS_RELEASE} ${CMAKE_MODULE_PATH})

########## COMPONENTS TARGET PROPERTIES Release ########################################

    ########## COMPONENT civetweb::civetweb-cpp #############

        set(civetweb_civetweb_civetweb-cpp_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(civetweb_civetweb_civetweb-cpp_FRAMEWORKS_FOUND_RELEASE "${civetweb_civetweb_civetweb-cpp_FRAMEWORKS_RELEASE}" "${civetweb_civetweb_civetweb-cpp_FRAMEWORK_DIRS_RELEASE}")

        set(civetweb_civetweb_civetweb-cpp_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET civetweb_civetweb_civetweb-cpp_DEPS_TARGET)
            add_library(civetweb_civetweb_civetweb-cpp_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET civetweb_civetweb_civetweb-cpp_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'civetweb_civetweb_civetweb-cpp_DEPS_TARGET' to all of them
        conan_package_library_targets("${civetweb_civetweb_civetweb-cpp_LIBS_RELEASE}"
                              "${civetweb_civetweb_civetweb-cpp_LIB_DIRS_RELEASE}"
                              "${civetweb_civetweb_civetweb-cpp_BIN_DIRS_RELEASE}" # package_bindir
                              "${civetweb_civetweb_civetweb-cpp_LIBRARY_TYPE_RELEASE}"
                              "${civetweb_civetweb_civetweb-cpp_IS_HOST_WINDOWS_RELEASE}"
                              civetweb_civetweb_civetweb-cpp_DEPS_TARGET
                              civetweb_civetweb_civetweb-cpp_LIBRARIES_TARGETS
                              "_RELEASE"
                              "civetweb_civetweb_civetweb-cpp"
                              "${civetweb_civetweb_civetweb-cpp_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET civetweb::civetweb-cpp
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_LIBRARIES_TARGETS}>
                     )

        if("${civetweb_civetweb_civetweb-cpp_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET civetweb::civetweb-cpp
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         civetweb_civetweb_civetweb-cpp_DEPS_TARGET)
        endif()

        set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_LIB_DIRS_RELEASE}>)
        set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_RELEASE}>)


    ########## COMPONENT civetweb::civetweb #############

        set(civetweb_civetweb_civetweb_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(civetweb_civetweb_civetweb_FRAMEWORKS_FOUND_RELEASE "${civetweb_civetweb_civetweb_FRAMEWORKS_RELEASE}" "${civetweb_civetweb_civetweb_FRAMEWORK_DIRS_RELEASE}")

        set(civetweb_civetweb_civetweb_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET civetweb_civetweb_civetweb_DEPS_TARGET)
            add_library(civetweb_civetweb_civetweb_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET civetweb_civetweb_civetweb_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'civetweb_civetweb_civetweb_DEPS_TARGET' to all of them
        conan_package_library_targets("${civetweb_civetweb_civetweb_LIBS_RELEASE}"
                              "${civetweb_civetweb_civetweb_LIB_DIRS_RELEASE}"
                              "${civetweb_civetweb_civetweb_BIN_DIRS_RELEASE}" # package_bindir
                              "${civetweb_civetweb_civetweb_LIBRARY_TYPE_RELEASE}"
                              "${civetweb_civetweb_civetweb_IS_HOST_WINDOWS_RELEASE}"
                              civetweb_civetweb_civetweb_DEPS_TARGET
                              civetweb_civetweb_civetweb_LIBRARIES_TARGETS
                              "_RELEASE"
                              "civetweb_civetweb_civetweb"
                              "${civetweb_civetweb_civetweb_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET civetweb::civetweb
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_LIBRARIES_TARGETS}>
                     )

        if("${civetweb_civetweb_civetweb_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET civetweb::civetweb
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         civetweb_civetweb_civetweb_DEPS_TARGET)
        endif()

        set_property(TARGET civetweb::civetweb APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET civetweb::civetweb APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET civetweb::civetweb APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_LIB_DIRS_RELEASE}>)
        set_property(TARGET civetweb::civetweb APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET civetweb::civetweb APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${civetweb_civetweb_civetweb_COMPILE_OPTIONS_RELEASE}>)


    ########## AGGREGATED GLOBAL TARGET WITH THE COMPONENTS #####################
    set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_LINK_LIBRARIES civetweb::civetweb-cpp)
    set_property(TARGET civetweb::civetweb-cpp APPEND PROPERTY INTERFACE_LINK_LIBRARIES civetweb::civetweb)

########## For the modules (FindXXX)
set(civetweb_LIBRARIES_RELEASE civetweb::civetweb-cpp)
