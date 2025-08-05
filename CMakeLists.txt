cmake_minimum_required(VERSION 3.15)

# Define the project and specify C++17
project(new_obd2_tool_cpp VERSION 1.3.0 LANGUAGES CXX)

# Set C++ standard to C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable Unicode for Windows builds
if(WIN32)
    add_definitions(-DUNICODE -D_UNICODE)
endif()

# Set proper output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Set output directories for multi-config generators (Visual Studio)
foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
endforeach()

# Visual Studio-specific settings
if(MSVC)
    # Enable warnings
    add_compile_options(/W4)
    
    # Treat warnings as errors (optional, can be disabled if needed)
    # add_compile_options(/WX)
    
    # Enable parallel compilation
    add_compile_options(/MP)
    
    # Set the startup project for Visual Studio
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()

# Collect all source and header files recursively from src/ directory
file(GLOB_RECURSE SOURCES
    "src/*.cpp"
    "src/*.cxx"
    "src/*.cc"
    "src/*.c"
)

file(GLOB_RECURSE HEADERS
    "src/*.h"
    "src/*.hpp"
    "src/*.hxx"
)

# Create the executable target
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

# Set target properties for Visual Studio
if(MSVC)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )
endif()

# Allow for future library linking - example of how to link libraries
# target_link_libraries(${PROJECT_NAME} PRIVATE 
#     # Add your libraries here
#     # example: some_library
# )

# Include directories (if needed for headers)
target_include_directories(${PROJECT_NAME} PRIVATE src)

# Platform-specific configurations
if(WIN32)
    # Windows-specific settings
    target_compile_definitions(${PROJECT_NAME} PRIVATE 
        WIN32_LEAN_AND_MEAN
        NOMINMAX
    )
elseif(UNIX AND NOT APPLE)
    # Linux-specific settings
    target_link_libraries(${PROJECT_NAME} PRIVATE pthread)
elseif(APPLE)
    # macOS-specific settings
    target_compile_definitions(${PROJECT_NAME} PRIVATE MACOS)
endif()

# Installation rules for the executable
include(GNUInstallDirs)

# Install the executable
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Install any additional files if needed (configuration files, etc.)
# install(FILES config/app.conf DESTINATION ${CMAKE_INSTALL_SYSCONFDIR})

# Create an uninstall target (optional)
if(NOT TARGET uninstall)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY
    )
    
    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "Configuration Summary:")
message(STATUS "  Project Name: ${PROJECT_NAME}")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: C++${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Runtime Output: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
message(STATUS "")