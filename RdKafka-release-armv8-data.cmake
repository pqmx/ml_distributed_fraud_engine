########### AGGREGATED COMPONENTS AND DEPENDENCIES FOR THE MULTI CONFIG #####################
#############################################################################################

list(APPEND librdkafka_COMPONENT_NAMES RdKafka::rdkafka RdKafka::rdkafka++)
list(REMOVE_DUPLICATES librdkafka_COMPONENT_NAMES)
if(DEFINED librdkafka_FIND_DEPENDENCY_NAMES)
  list(APPEND librdkafka_FIND_DEPENDENCY_NAMES lz4)
  list(REMOVE_DUPLICATES librdkafka_FIND_DEPENDENCY_NAMES)
else()
  set(librdkafka_FIND_DEPENDENCY_NAMES lz4)
endif()
set(lz4_FIND_MODE "NO_MODULE")

########### VARIABLES #######################################################################
#############################################################################################
set(librdkafka_PACKAGE_FOLDER_RELEASE "/Users/prestonmamaril/.conan2/p/b/librdf3deeff7ef609/p")
set(librdkafka_BUILD_MODULES_PATHS_RELEASE )


set(librdkafka_INCLUDE_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/include")
set(librdkafka_RES_DIRS_RELEASE )
set(librdkafka_DEFINITIONS_RELEASE "-DLIBRDKAFKA_STATICLIB")
set(librdkafka_SHARED_LINK_FLAGS_RELEASE )
set(librdkafka_EXE_LINK_FLAGS_RELEASE )
set(librdkafka_OBJECTS_RELEASE )
set(librdkafka_COMPILE_DEFINITIONS_RELEASE "LIBRDKAFKA_STATICLIB")
set(librdkafka_COMPILE_OPTIONS_C_RELEASE )
set(librdkafka_COMPILE_OPTIONS_CXX_RELEASE )
set(librdkafka_LIB_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/lib")
set(librdkafka_BIN_DIRS_RELEASE )
set(librdkafka_LIBRARY_TYPE_RELEASE STATIC)
set(librdkafka_IS_HOST_WINDOWS_RELEASE 0)
set(librdkafka_LIBS_RELEASE rdkafka++ rdkafka)
set(librdkafka_SYSTEM_LIBS_RELEASE )
set(librdkafka_FRAMEWORK_DIRS_RELEASE )
set(librdkafka_FRAMEWORKS_RELEASE )
set(librdkafka_BUILD_DIRS_RELEASE )
set(librdkafka_NO_SONAME_MODE_RELEASE FALSE)


# COMPOUND VARIABLES
set(librdkafka_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${librdkafka_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${librdkafka_COMPILE_OPTIONS_C_RELEASE}>")
set(librdkafka_LINKER_FLAGS_RELEASE
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${librdkafka_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${librdkafka_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${librdkafka_EXE_LINK_FLAGS_RELEASE}>")


set(librdkafka_COMPONENTS_RELEASE RdKafka::rdkafka RdKafka::rdkafka++)
########### COMPONENT RdKafka::rdkafka++ VARIABLES ############################################

set(librdkafka_RdKafka_rdkafka++_INCLUDE_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/include")
set(librdkafka_RdKafka_rdkafka++_LIB_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/lib")
set(librdkafka_RdKafka_rdkafka++_BIN_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_LIBRARY_TYPE_RELEASE STATIC)
set(librdkafka_RdKafka_rdkafka++_IS_HOST_WINDOWS_RELEASE 0)
set(librdkafka_RdKafka_rdkafka++_RES_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_DEFINITIONS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_OBJECTS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_COMPILE_DEFINITIONS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_C_RELEASE "")
set(librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_CXX_RELEASE "")
set(librdkafka_RdKafka_rdkafka++_LIBS_RELEASE rdkafka++)
set(librdkafka_RdKafka_rdkafka++_SYSTEM_LIBS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_FRAMEWORK_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_FRAMEWORKS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_DEPENDENCIES_RELEASE RdKafka::rdkafka)
set(librdkafka_RdKafka_rdkafka++_SHARED_LINK_FLAGS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_EXE_LINK_FLAGS_RELEASE )
set(librdkafka_RdKafka_rdkafka++_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(librdkafka_RdKafka_rdkafka++_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${librdkafka_RdKafka_rdkafka++_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${librdkafka_RdKafka_rdkafka++_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${librdkafka_RdKafka_rdkafka++_EXE_LINK_FLAGS_RELEASE}>
)
set(librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${librdkafka_RdKafka_rdkafka++_COMPILE_OPTIONS_C_RELEASE}>")
########### COMPONENT RdKafka::rdkafka VARIABLES ############################################

set(librdkafka_RdKafka_rdkafka_INCLUDE_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/include")
set(librdkafka_RdKafka_rdkafka_LIB_DIRS_RELEASE "${librdkafka_PACKAGE_FOLDER_RELEASE}/lib")
set(librdkafka_RdKafka_rdkafka_BIN_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka_LIBRARY_TYPE_RELEASE STATIC)
set(librdkafka_RdKafka_rdkafka_IS_HOST_WINDOWS_RELEASE 0)
set(librdkafka_RdKafka_rdkafka_RES_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka_DEFINITIONS_RELEASE "-DLIBRDKAFKA_STATICLIB")
set(librdkafka_RdKafka_rdkafka_OBJECTS_RELEASE )
set(librdkafka_RdKafka_rdkafka_COMPILE_DEFINITIONS_RELEASE "LIBRDKAFKA_STATICLIB")
set(librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_C_RELEASE "")
set(librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_CXX_RELEASE "")
set(librdkafka_RdKafka_rdkafka_LIBS_RELEASE rdkafka)
set(librdkafka_RdKafka_rdkafka_SYSTEM_LIBS_RELEASE )
set(librdkafka_RdKafka_rdkafka_FRAMEWORK_DIRS_RELEASE )
set(librdkafka_RdKafka_rdkafka_FRAMEWORKS_RELEASE )
set(librdkafka_RdKafka_rdkafka_DEPENDENCIES_RELEASE LZ4::lz4_static)
set(librdkafka_RdKafka_rdkafka_SHARED_LINK_FLAGS_RELEASE )
set(librdkafka_RdKafka_rdkafka_EXE_LINK_FLAGS_RELEASE )
set(librdkafka_RdKafka_rdkafka_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(librdkafka_RdKafka_rdkafka_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${librdkafka_RdKafka_rdkafka_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${librdkafka_RdKafka_rdkafka_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${librdkafka_RdKafka_rdkafka_EXE_LINK_FLAGS_RELEASE}>
)
set(librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${librdkafka_RdKafka_rdkafka_COMPILE_OPTIONS_C_RELEASE}>")