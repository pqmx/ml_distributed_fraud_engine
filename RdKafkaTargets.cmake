# Load the debug and release variables
file(GLOB DATA_FILES "${CMAKE_CURRENT_LIST_DIR}/RdKafka-*-data.cmake")

foreach(f ${DATA_FILES})
    include(${f})
endforeach()

# Create the targets for all the components
foreach(_COMPONENT ${librdkafka_COMPONENT_NAMES} )
    if(NOT TARGET ${_COMPONENT})
        add_library(${_COMPONENT} INTERFACE IMPORTED)
        message(${RdKafka_MESSAGE_MODE} "Conan: Component target declared '${_COMPONENT}'")
    endif()
endforeach()

if(NOT TARGET RdKafka::rdkafka++)
    add_library(RdKafka::rdkafka++ INTERFACE IMPORTED)
    message(${RdKafka_MESSAGE_MODE} "Conan: Target declared 'RdKafka::rdkafka++'")
endif()
# Load the debug and release library finders
file(GLOB CONFIG_FILES "${CMAKE_CURRENT_LIST_DIR}/RdKafka-Target-*.cmake")

foreach(f ${CONFIG_FILES})
    include(${f})
endforeach()