# Avoid multiple calls to find_package to append duplicated properties to the targets
include_guard()########### VARIABLES #######################################################################
#############################################################################################
set(librdkafka_FRAMEWORKS_FOUND_RELEASE "") # Will be filled later
conan_find_apple_frameworks(librdkafka_FRAMEWORKS_FOUND_RELEASE "${librdkafka_FRAMEWORKS_RELEASE}" "${librdkafka_FRAMEWORK_DIRS_RELEASE}")

set(librdkafka_LIBRARIES_TARGETS "") # Will be filled later


######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
if(NOT TARGET librdkafka_DEPS_TARGET)
    add_library(librdkafka_DEPS_TARGET INTERFACE IMPORTED)
endif()

set_property(TARGET librdkafka_DEPS_TARGET
             APPEND PROPERTY INTERFACE_LINK_LIBRARIES
             $<$<CONFIG:Release>:${librdkafka_FRAMEWORKS_FOUND_RELEASE}>
             $<$<CONFIG:Release>:${librdkafka_SYSTEM_LIBS_RELEASE}>
             $<$<CONFIG:Release>:LZ4::lz4_static;RdKafka::rdkafka>)

####### Find the libraries declared in cpp_info.libs, create an IMPORTED target for each one and link the
####### librdkafka_DEPS_TARGET to all of them
conan_package_library_targets("${librdkafka_LIBS_RELEASE}"    # libraries
                              "${librdkafka_LIB_DIRS_RELEASE}" # package_libdir
                              "${librdkafka_BIN_DIRS_RELEASE}" # package_bindir
                              "${librdkafka_LIBRARY_TYPE_RELEASE}"
                              "${librdkafka_IS_HOST_WINDOWS_RELEASE}"
                              librdkafka_DEPS_TARGET
                              librdkafka_LIBRARIES_TARGETS  # out_libraries_targets
                              "_RELEASE"
                              "librdkafka"    # package_name
                              "${librdkafka_NO_SONAME_MODE_RELEASE}")  # soname

# FIXME: What is the result of this for multi-config? All configs adding themselves to path?
set(CMAKE_MODULE_PATH ${librdkafka_BUILD_DIRS_RELEASE} ${CMAKE_MODULE_PATH})

########## COMPONENTS TARGET PROPERTIES Release ########################################

    ########## COMPONENT RdKafka::rdkafka++ #############

        set(librdkafka_RdKafka_rdkafka++_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(librdkafka_RdKafka_rdkafka++_FRAMEWORKS_FOUND_RELEASE "${librdkafka_RdKafka_rdkafka++_FRAMEWORKS_RELEASE}" "${librdkafka_RdKafka_rdkafka++_FRAMEWORK_DIRS_RELEASE}")

        set(librdkafka_RdKafka_rdkafka++_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET librdkafka_RdKafka_rdkafka++_DEPS_TARGET)
            add_library(librdkafka_RdKafka_rdkafka++_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET librdkafka_RdKafka_rdkafka++_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'librdkafka_RdKafka_rdkafka++_DEPS_TARGET' to all of them
        conan_package_library_targets("${librdkafka_RdKafka_rdkafka++_LIBS_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka++_LIB_DIRS_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka++_BIN_DIRS_RELEASE}" # package_bindir
                              "${librdkafka_RdKafka_rdkafka++_LIBRARY_TYPE_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka++_IS_HOST_WINDOWS_RELEASE}"
                              librdkafka_RdKafka_rdkafka++_DEPS_TARGET
                              librdkafka_RdKafka_rdkafka++_LIBRARIES_TARGETS
                              "_RELEASE"
                              "librdkafka_RdKafka_rdkafka++"
                              "${librdkafka_RdKafka_rdkafka++_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET RdKafka::rdkafka++
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_LIBRARIES_TARGETS}>
                     )

        if("${librdkafka_RdKafka_rdkafka++_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET RdKafka::rdkafka++
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         librdkafka_RdKafka_rdkafka++_DEPS_TARGET)
        endif()

        set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_LIB_DIRS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_RELEASE}>)


    ########## COMPONENT RdKafka::rdkafka #############

        set(librdkafka_RdKafka_rdkafka_FRAMEWORKS_FOUND_RELEASE "")
        conan_find_apple_frameworks(librdkafka_RdKafka_rdkafka_FRAMEWORKS_FOUND_RELEASE "${librdkafka_RdKafka_rdkafka_FRAMEWORKS_RELEASE}" "${librdkafka_RdKafka_rdkafka_FRAMEWORK_DIRS_RELEASE}")

        set(librdkafka_RdKafka_rdkafka_LIBRARIES_TARGETS "")

        ######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
        if(NOT TARGET librdkafka_RdKafka_rdkafka_DEPS_TARGET)
            add_library(librdkafka_RdKafka_rdkafka_DEPS_TARGET INTERFACE IMPORTED)
        endif()

        set_property(TARGET librdkafka_RdKafka_rdkafka_DEPS_TARGET
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_FRAMEWORKS_FOUND_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_SYSTEM_LIBS_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_DEPENDENCIES_RELEASE}>
                     )

        ####### Find the libraries declared in cpp_info.component["xxx"].libs,
        ####### create an IMPORTED target for each one and link the 'librdkafka_RdKafka_rdkafka_DEPS_TARGET' to all of them
        conan_package_library_targets("${librdkafka_RdKafka_rdkafka_LIBS_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka_LIB_DIRS_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka_BIN_DIRS_RELEASE}" # package_bindir
                              "${librdkafka_RdKafka_rdkafka_LIBRARY_TYPE_RELEASE}"
                              "${librdkafka_RdKafka_rdkafka_IS_HOST_WINDOWS_RELEASE}"
                              librdkafka_RdKafka_rdkafka_DEPS_TARGET
                              librdkafka_RdKafka_rdkafka_LIBRARIES_TARGETS
                              "_RELEASE"
                              "librdkafka_RdKafka_rdkafka"
                              "${librdkafka_RdKafka_rdkafka_NO_SONAME_MODE_RELEASE}")


        ########## TARGET PROPERTIES #####################################
        set_property(TARGET RdKafka::rdkafka
                     APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_OBJECTS_RELEASE}>
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_LIBRARIES_TARGETS}>
                     )

        if("${librdkafka_RdKafka_rdkafka_LIBS_RELEASE}" STREQUAL "")
            # If the component is not declaring any "cpp_info.components['foo'].libs" the system, frameworks etc are not
            # linked to the imported targets and we need to do it to the global target
            set_property(TARGET RdKafka::rdkafka
                         APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                         librdkafka_RdKafka_rdkafka_DEPS_TARGET)
        endif()

        set_property(TARGET RdKafka::rdkafka APPEND PROPERTY INTERFACE_LINK_OPTIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_LINKER_FLAGS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_INCLUDE_DIRS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka APPEND PROPERTY INTERFACE_LINK_DIRECTORIES
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_LIB_DIRS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_COMPILE_DEFINITIONS_RELEASE}>)
        set_property(TARGET RdKafka::rdkafka APPEND PROPERTY INTERFACE_COMPILE_OPTIONS
                     $<$<CONFIG:Release>:${librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_RELEASE}>)


    ########## AGGREGATED GLOBAL TARGET WITH THE COMPONENTS #####################
    set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_LINK_LIBRARIES RdKafka::rdkafka++)
    set_property(TARGET RdKafka::rdkafka++ APPEND PROPERTY INTERFACE_LINK_LIBRARIES RdKafka::rdkafka)

########## For the modules (FindXXX)
set(librdkafka_LIBRARIES_RELEASE RdKafka::rdkafka++)
