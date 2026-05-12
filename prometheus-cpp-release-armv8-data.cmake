########### AGGREGATED COMPONENTS AND DEPENDENCIES FOR THE MULTI CONFIG #####################
#############################################################################################

list(APPEND prometheus-cpp_COMPONENT_NAMES prometheus-cpp::core prometheus-cpp::push prometheus-cpp::pull)
list(REMOVE_DUPLICATES prometheus-cpp_COMPONENT_NAMES)
if(DEFINED prometheus-cpp_FIND_DEPENDENCY_NAMES)
  list(APPEND prometheus-cpp_FIND_DEPENDENCY_NAMES civetweb CURL ZLIB)
  list(REMOVE_DUPLICATES prometheus-cpp_FIND_DEPENDENCY_NAMES)
else()
  set(prometheus-cpp_FIND_DEPENDENCY_NAMES civetweb CURL ZLIB)
endif()
set(civetweb_FIND_MODE "NO_MODULE")
set(CURL_FIND_MODE "NO_MODULE")
set(ZLIB_FIND_MODE "NO_MODULE")

########### VARIABLES #######################################################################
#############################################################################################
set(prometheus-cpp_PACKAGE_FOLDER_RELEASE "/Users/prestonmamaril/.conan2/p/b/prome45985d7ad686e/p")
set(prometheus-cpp_BUILD_MODULES_PATHS_RELEASE )


set(prometheus-cpp_INCLUDE_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/include")
set(prometheus-cpp_RES_DIRS_RELEASE )
set(prometheus-cpp_DEFINITIONS_RELEASE )
set(prometheus-cpp_SHARED_LINK_FLAGS_RELEASE )
set(prometheus-cpp_EXE_LINK_FLAGS_RELEASE )
set(prometheus-cpp_OBJECTS_RELEASE )
set(prometheus-cpp_COMPILE_DEFINITIONS_RELEASE )
set(prometheus-cpp_COMPILE_OPTIONS_C_RELEASE )
set(prometheus-cpp_COMPILE_OPTIONS_CXX_RELEASE )
set(prometheus-cpp_LIB_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/lib")
set(prometheus-cpp_BIN_DIRS_RELEASE )
set(prometheus-cpp_LIBRARY_TYPE_RELEASE STATIC)
set(prometheus-cpp_IS_HOST_WINDOWS_RELEASE 0)
set(prometheus-cpp_LIBS_RELEASE prometheus-cpp-pull prometheus-cpp-push prometheus-cpp-core)
set(prometheus-cpp_SYSTEM_LIBS_RELEASE )
set(prometheus-cpp_FRAMEWORK_DIRS_RELEASE )
set(prometheus-cpp_FRAMEWORKS_RELEASE )
set(prometheus-cpp_BUILD_DIRS_RELEASE )
set(prometheus-cpp_NO_SONAME_MODE_RELEASE FALSE)


# COMPOUND VARIABLES
set(prometheus-cpp_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${prometheus-cpp_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${prometheus-cpp_COMPILE_OPTIONS_C_RELEASE}>")
set(prometheus-cpp_LINKER_FLAGS_RELEASE
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${prometheus-cpp_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${prometheus-cpp_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${prometheus-cpp_EXE_LINK_FLAGS_RELEASE}>")


set(prometheus-cpp_COMPONENTS_RELEASE prometheus-cpp::core prometheus-cpp::push prometheus-cpp::pull)
########### COMPONENT prometheus-cpp::pull VARIABLES ############################################

set(prometheus-cpp_prometheus-cpp_pull_INCLUDE_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/include")
set(prometheus-cpp_prometheus-cpp_pull_LIB_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/lib")
set(prometheus-cpp_prometheus-cpp_pull_BIN_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_LIBRARY_TYPE_RELEASE STATIC)
set(prometheus-cpp_prometheus-cpp_pull_IS_HOST_WINDOWS_RELEASE 0)
set(prometheus-cpp_prometheus-cpp_pull_RES_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_OBJECTS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_COMPILE_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_C_RELEASE "")
set(prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_CXX_RELEASE "")
set(prometheus-cpp_prometheus-cpp_pull_LIBS_RELEASE prometheus-cpp-pull)
set(prometheus-cpp_prometheus-cpp_pull_SYSTEM_LIBS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_FRAMEWORK_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_FRAMEWORKS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_DEPENDENCIES_RELEASE prometheus-cpp::core civetweb::civetweb-cpp ZLIB::ZLIB)
set(prometheus-cpp_prometheus-cpp_pull_SHARED_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_EXE_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_pull_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(prometheus-cpp_prometheus-cpp_pull_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${prometheus-cpp_prometheus-cpp_pull_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${prometheus-cpp_prometheus-cpp_pull_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${prometheus-cpp_prometheus-cpp_pull_EXE_LINK_FLAGS_RELEASE}>
)
set(prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${prometheus-cpp_prometheus-cpp_pull_COMPILE_OPTIONS_C_RELEASE}>")
########### COMPONENT prometheus-cpp::push VARIABLES ############################################

set(prometheus-cpp_prometheus-cpp_push_INCLUDE_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/include")
set(prometheus-cpp_prometheus-cpp_push_LIB_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/lib")
set(prometheus-cpp_prometheus-cpp_push_BIN_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_LIBRARY_TYPE_RELEASE STATIC)
set(prometheus-cpp_prometheus-cpp_push_IS_HOST_WINDOWS_RELEASE 0)
set(prometheus-cpp_prometheus-cpp_push_RES_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_OBJECTS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_COMPILE_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_C_RELEASE "")
set(prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_CXX_RELEASE "")
set(prometheus-cpp_prometheus-cpp_push_LIBS_RELEASE prometheus-cpp-push)
set(prometheus-cpp_prometheus-cpp_push_SYSTEM_LIBS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_FRAMEWORK_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_FRAMEWORKS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_DEPENDENCIES_RELEASE prometheus-cpp::core CURL::libcurl)
set(prometheus-cpp_prometheus-cpp_push_SHARED_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_EXE_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_push_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(prometheus-cpp_prometheus-cpp_push_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${prometheus-cpp_prometheus-cpp_push_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${prometheus-cpp_prometheus-cpp_push_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${prometheus-cpp_prometheus-cpp_push_EXE_LINK_FLAGS_RELEASE}>
)
set(prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${prometheus-cpp_prometheus-cpp_push_COMPILE_OPTIONS_C_RELEASE}>")
########### COMPONENT prometheus-cpp::core VARIABLES ############################################

set(prometheus-cpp_prometheus-cpp_core_INCLUDE_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/include")
set(prometheus-cpp_prometheus-cpp_core_LIB_DIRS_RELEASE "${prometheus-cpp_PACKAGE_FOLDER_RELEASE}/lib")
set(prometheus-cpp_prometheus-cpp_core_BIN_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_LIBRARY_TYPE_RELEASE STATIC)
set(prometheus-cpp_prometheus-cpp_core_IS_HOST_WINDOWS_RELEASE 0)
set(prometheus-cpp_prometheus-cpp_core_RES_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_OBJECTS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_COMPILE_DEFINITIONS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_C_RELEASE "")
set(prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_CXX_RELEASE "")
set(prometheus-cpp_prometheus-cpp_core_LIBS_RELEASE prometheus-cpp-core)
set(prometheus-cpp_prometheus-cpp_core_SYSTEM_LIBS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_FRAMEWORK_DIRS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_FRAMEWORKS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_DEPENDENCIES_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_SHARED_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_EXE_LINK_FLAGS_RELEASE )
set(prometheus-cpp_prometheus-cpp_core_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(prometheus-cpp_prometheus-cpp_core_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${prometheus-cpp_prometheus-cpp_core_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${prometheus-cpp_prometheus-cpp_core_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${prometheus-cpp_prometheus-cpp_core_EXE_LINK_FLAGS_RELEASE}>
)
set(prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${prometheus-cpp_prometheus-cpp_core_COMPILE_OPTIONS_C_RELEASE}>")