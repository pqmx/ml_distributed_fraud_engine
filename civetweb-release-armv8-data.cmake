########### AGGREGATED COMPONENTS AND DEPENDENCIES FOR THE MULTI CONFIG #####################
#############################################################################################

list(APPEND civetweb_COMPONENT_NAMES civetweb::civetweb civetweb::civetweb-cpp)
list(REMOVE_DUPLICATES civetweb_COMPONENT_NAMES)
if(DEFINED civetweb_FIND_DEPENDENCY_NAMES)
  list(APPEND civetweb_FIND_DEPENDENCY_NAMES OpenSSL)
  list(REMOVE_DUPLICATES civetweb_FIND_DEPENDENCY_NAMES)
else()
  set(civetweb_FIND_DEPENDENCY_NAMES OpenSSL)
endif()
set(OpenSSL_FIND_MODE "NO_MODULE")

########### VARIABLES #######################################################################
#############################################################################################
set(civetweb_PACKAGE_FOLDER_RELEASE "/Users/prestonmamaril/.conan2/p/b/civetd88af7e436584/p")
set(civetweb_BUILD_MODULES_PATHS_RELEASE )


set(civetweb_INCLUDE_DIRS_RELEASE )
set(civetweb_RES_DIRS_RELEASE )
set(civetweb_DEFINITIONS_RELEASE )
set(civetweb_SHARED_LINK_FLAGS_RELEASE )
set(civetweb_EXE_LINK_FLAGS_RELEASE )
set(civetweb_OBJECTS_RELEASE )
set(civetweb_COMPILE_DEFINITIONS_RELEASE )
set(civetweb_COMPILE_OPTIONS_C_RELEASE )
set(civetweb_COMPILE_OPTIONS_CXX_RELEASE )
set(civetweb_LIB_DIRS_RELEASE "${civetweb_PACKAGE_FOLDER_RELEASE}/lib")
set(civetweb_BIN_DIRS_RELEASE )
set(civetweb_LIBRARY_TYPE_RELEASE STATIC)
set(civetweb_IS_HOST_WINDOWS_RELEASE 0)
set(civetweb_LIBS_RELEASE civetweb-cpp civetweb)
set(civetweb_SYSTEM_LIBS_RELEASE )
set(civetweb_FRAMEWORK_DIRS_RELEASE )
set(civetweb_FRAMEWORKS_RELEASE Cocoa)
set(civetweb_BUILD_DIRS_RELEASE )
set(civetweb_NO_SONAME_MODE_RELEASE FALSE)


# COMPOUND VARIABLES
set(civetweb_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${civetweb_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${civetweb_COMPILE_OPTIONS_C_RELEASE}>")
set(civetweb_LINKER_FLAGS_RELEASE
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${civetweb_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${civetweb_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${civetweb_EXE_LINK_FLAGS_RELEASE}>")


set(civetweb_COMPONENTS_RELEASE civetweb::civetweb civetweb::civetweb-cpp)
########### COMPONENT civetweb::civetweb-cpp VARIABLES ############################################

set(civetweb_civetweb_civetweb-cpp_INCLUDE_DIRS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_LIB_DIRS_RELEASE "${civetweb_PACKAGE_FOLDER_RELEASE}/lib")
set(civetweb_civetweb_civetweb-cpp_BIN_DIRS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_LIBRARY_TYPE_RELEASE STATIC)
set(civetweb_civetweb_civetweb-cpp_IS_HOST_WINDOWS_RELEASE 0)
set(civetweb_civetweb_civetweb-cpp_RES_DIRS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_DEFINITIONS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_OBJECTS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_COMPILE_DEFINITIONS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_C_RELEASE "")
set(civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_CXX_RELEASE "")
set(civetweb_civetweb_civetweb-cpp_LIBS_RELEASE civetweb-cpp)
set(civetweb_civetweb_civetweb-cpp_SYSTEM_LIBS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_FRAMEWORK_DIRS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_FRAMEWORKS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_DEPENDENCIES_RELEASE civetweb::civetweb)
set(civetweb_civetweb_civetweb-cpp_SHARED_LINK_FLAGS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_EXE_LINK_FLAGS_RELEASE )
set(civetweb_civetweb_civetweb-cpp_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(civetweb_civetweb_civetweb-cpp_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${civetweb_civetweb_civetweb-cpp_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${civetweb_civetweb_civetweb-cpp_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${civetweb_civetweb_civetweb-cpp_EXE_LINK_FLAGS_RELEASE}>
)
set(civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${civetweb_civetweb_civetweb-cpp_COMPILE_OPTIONS_C_RELEASE}>")
########### COMPONENT civetweb::civetweb VARIABLES ############################################

set(civetweb_civetweb_civetweb_INCLUDE_DIRS_RELEASE )
set(civetweb_civetweb_civetweb_LIB_DIRS_RELEASE "${civetweb_PACKAGE_FOLDER_RELEASE}/lib")
set(civetweb_civetweb_civetweb_BIN_DIRS_RELEASE )
set(civetweb_civetweb_civetweb_LIBRARY_TYPE_RELEASE STATIC)
set(civetweb_civetweb_civetweb_IS_HOST_WINDOWS_RELEASE 0)
set(civetweb_civetweb_civetweb_RES_DIRS_RELEASE )
set(civetweb_civetweb_civetweb_DEFINITIONS_RELEASE )
set(civetweb_civetweb_civetweb_OBJECTS_RELEASE )
set(civetweb_civetweb_civetweb_COMPILE_DEFINITIONS_RELEASE )
set(civetweb_civetweb_civetweb_COMPILE_OPTIONS_C_RELEASE "")
set(civetweb_civetweb_civetweb_COMPILE_OPTIONS_CXX_RELEASE "")
set(civetweb_civetweb_civetweb_LIBS_RELEASE civetweb)
set(civetweb_civetweb_civetweb_SYSTEM_LIBS_RELEASE )
set(civetweb_civetweb_civetweb_FRAMEWORK_DIRS_RELEASE )
set(civetweb_civetweb_civetweb_FRAMEWORKS_RELEASE Cocoa)
set(civetweb_civetweb_civetweb_DEPENDENCIES_RELEASE openssl::openssl)
set(civetweb_civetweb_civetweb_SHARED_LINK_FLAGS_RELEASE )
set(civetweb_civetweb_civetweb_EXE_LINK_FLAGS_RELEASE )
set(civetweb_civetweb_civetweb_NO_SONAME_MODE_RELEASE FALSE)

# COMPOUND VARIABLES
set(civetweb_civetweb_civetweb_LINKER_FLAGS_RELEASE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${civetweb_civetweb_civetweb_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${civetweb_civetweb_civetweb_SHARED_LINK_FLAGS_RELEASE}>
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${civetweb_civetweb_civetweb_EXE_LINK_FLAGS_RELEASE}>
)
set(civetweb_civetweb_civetweb_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${civetweb_civetweb_civetweb_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${civetweb_civetweb_civetweb_COMPILE_OPTIONS_C_RELEASE}>")