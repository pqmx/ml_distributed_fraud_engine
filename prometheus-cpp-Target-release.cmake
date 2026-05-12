# Avoid multiple calls to find_package to append duplicated properties to the targets
include_guard()########### VARIABLES #######################################################################
#############################################################################################
set(prometheus-cpp_FRAMEWORKS_FOUND_RELEASE "") # Will be filled later
conan_find_apple_frameworks(prometheus-cpp_FRAMEWORKS_FOUND_RELEASE "${prometheus-cpp_FRAMEWORKS_RELEASE}" "${prometheus-cpp_FRAMEWORK_DIRS_RELEASE}")

set(prometheus-cpp_LIBRARIES_TARGETS "") # Will be filled later


######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
if(NOT TARGET prometheus-cpp_DEPS_TARGET)
    add_library(prometheus-cpp_DEPS_TARGET INTERFACE IMPORTED)
endif()

set_property(TARGET prometheus-cpp_DEPS_TARGET
             APPEND PROPERTY INTERFACE_LINK_LIBRARIES
             $<$<CONFIG:Release>:${prometheus-cpp_FRAMEWORKS_FOUND_RELEASE}>
             $<$<CONFIG:Release>:${prometheus-cpp_SYSTEM_LIBS_RELEASE}>
             $<$<CONFIG:Release>:prometheus-cpp::core;CURL::libcurl;civetweb::civetweb-cpp;ZLIB::ZLIB>)

####### Find the libraries declared in cpp_info.libs, create an IMPORTED target for each one and link the
####### prometheus-cpp_DEPS_TARGET to all of them
conan_package_library_targets("${prometheus-cpp_LIBS_RELEASE}"    # libraries
                              "${prometheus-cpp_LIB_DIRS_RELEASE}" # package_libdir
                              "${prometheus-cpp_BIN_DIRS_RELEASE}" # package_bindir
                              "${prometheus-cpp_LIBRARY_TYPE_RELEASE}"
                              "${prometheus-cpp_IS_HOST_WINDOWS_RELEASE}"
                              prometheus-cpp_DEPS_TARGET
                              prometheus-cpp_LIBRARIES_TARGETS  # out_libraries_targets
                              "_RELEASE"
                              "prometheus-cpp"    # package_name
                              "${prometheus-cpp_NO_SONAME_MODE_RELEASE}")  # soname

# FIXME: What is the result of this for multi-config? All configs adding themselves to path?
set(CMAKE_MODULE_PATH ${prometheus-cpp_BUILD_DIRS_RELEASE} ${CMAKE_MODULE_PATH})

########## COMPONENTS TARGET PROPERTIES Release ########################################

    ########## COMPONENT prometheus-cpp::pull #############

        set(prometheus-cpp_prometheus-cpp_pull_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(prometheus-cpp_prometheus-cpp_pull_FRAMEWORKS_FOUND_RELEASE "${prometheus-cpp_prometheus-cpp_pull_FRAMEWORKS_RELEASE}" "${prometheus-cpp_prometheus-cpp_pull_FRAMEWORK_DIRS_RELEASE}")

        set(prometheus-cpp_prometheus-cpp_pull_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET)
            add_library(prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET' to all of them
        conan_package_library_targets("${prometheus-cpp_prometheus-cpp_pull_LIBS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_pull_LIB_DIRS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_pull_BIN_DIRS_RELEASE}" # package_bindir
                              "${prometheus-cpp_prometheus-cpp_pull_LIBRARY_TYPE_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_pull_IS_HOST_WINDOWS_RELEASE}"
                              prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET
                              prometheus-cpp_prometheus-cpp_pull_LIBRARIES_TARGETS
                              "_RELEASE"
                              "prometheus-cpp_prometheus-cpp_pull"
                              "${prometheus-cpp_prometheus-cpp_pull_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET prometheus-cpp::pull
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_LIBRARIES_TARGETS}>
                     )

        if("${prometheus-cpp_prometheus-cpp_pull_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET prometheus-cpp::pull
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         prometheus-cpp_prometheus-cpp_pull_DEPS_TARGET)
        endif()

        set_property(TARGET prometheus-cpp::pull APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET prometheus-cpp::pull APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::pull APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_LIB_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::pull APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET prometheus-cpp::pull APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_RELEASE}>)


    ########## COMPONENT prometheus-cpp::push #############

        set(prometheus-cpp_prometheus-cpp_push_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(prometheus-cpp_prometheus-cpp_push_FRAMEWORKS_FOUND_RELEASE "${prometheus-cpp_prometheus-cpp_push_FRAMEWORKS_RELEASE}" "${prometheus-cpp_prometheus-cpp_push_FRAMEWORK_DIRS_RELEASE}")

        set(prometheus-cpp_prometheus-cpp_push_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET prometheus-cpp_prometheus-cpp_push_DEPS_TARGET)
            add_library(prometheus-cpp_prometheus-cpp_push_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET prometheus-cpp_prometheus-cpp_push_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'prometheus-cpp_prometheus-cpp_push_DEPS_TARGET' to all of them
        conan_package_library_targets("${prometheus-cpp_prometheus-cpp_push_LIBS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_push_LIB_DIRS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_push_BIN_DIRS_RELEASE}" # package_bindir
                              "${prometheus-cpp_prometheus-cpp_push_LIBRARY_TYPE_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_push_IS_HOST_WINDOWS_RELEASE}"
                              prometheus-cpp_prometheus-cpp_push_DEPS_TARGET
                              prometheus-cpp_prometheus-cpp_push_LIBRARIES_TARGETS
                              "_RELEASE"
                              "prometheus-cpp_prometheus-cpp_push"
                              "${prometheus-cpp_prometheus-cpp_push_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET prometheus-cpp::push
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_LIBRARIES_TARGETS}>
                     )

        if("${prometheus-cpp_prometheus-cpp_push_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET prometheus-cpp::push
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         prometheus-cpp_prometheus-cpp_push_DEPS_TARGET)
        endif()

        set_property(TARGET prometheus-cpp::push APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET prometheus-cpp::push APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::push APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_LIB_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::push APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET prometheus-cpp::push APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_RELEASE}>)


    ########## COMPONENT prometheus-cpp::core #############

        set(prometheus-cpp_prometheus-cpp_core_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(prometheus-cpp_prometheus-cpp_core_FRAMEWORKS_FOUND_RELEASE "${prometheus-cpp_prometheus-cpp_core_FRAMEWORKS_RELEASE}" "${prometheus-cpp_prometheus-cpp_core_FRAMEWORK_DIRS_RELEASE}")

        set(prometheus-cpp_prometheus-cpp_core_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET prometheus-cpp_prometheus-cpp_core_DEPS_TARGET)
            add_library(prometheus-cpp_prometheus-cpp_core_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET prometheus-cpp_prometheus-cpp_core_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'prometheus-cpp_prometheus-cpp_core_DEPS_TARGET' to all of them
        conan_package_library_targets("${prometheus-cpp_prometheus-cpp_core_LIBS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_core_LIB_DIRS_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_core_BIN_DIRS_RELEASE}" # package_bindir
                              "${prometheus-cpp_prometheus-cpp_core_LIBRARY_TYPE_RELEASE}"
                              "${prometheus-cpp_prometheus-cpp_core_IS_HOST_WINDOWS_RELEASE}"
                              prometheus-cpp_prometheus-cpp_core_DEPS_TARGET
                              prometheus-cpp_prometheus-cpp_core_LIBRARIES_TARGETS
                              "_RELEASE"
                              "prometheus-cpp_prometheus-cpp_core"
                              "${prometheus-cpp_prometheus-cpp_core_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET prometheus-cpp::core
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_LIBRARIES_TARGETS}>
                     )

        if("${prometheus-cpp_prometheus-cpp_core_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET prometheus-cpp::core
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         prometheus-cpp_prometheus-cpp_core_DEPS_TARGET)
        endif()

        set_property(TARGET prometheus-cpp::core APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET prometheus-cpp::core APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::core APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_LIB_DIRS_RELEASE}>)
        set_property(TARGET prometheus-cpp::core APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET prometheus-cpp::core APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_RELEASE}>)


    ########## AGGREGATED GLOBAL TARGET WITH THE COMPONENTS #####################
    set_property(TARGET prometheus-cpp::prometheus-cpp APPEND PROPERTY INTERFACE_LINK_LIBRARIES prometheus-cpp::pull)
    set_property(TARGET prometheus-cpp::prometheus-cpp APPEND PROPERTY INTERFACE_LINK_LIBRARIES prometheus-cpp::push)
    set_property(TARGET prometheus-cpp::prometheus-cpp APPEND PROPERTY INTERFACE_LINK_LIBRARIES prometheus-cpp::core)

########## For the modules (FindXXX)
set(prometheus-cpp_LIBRARIES_RELEASE prometheus-cpp::prometheus-cpp)
