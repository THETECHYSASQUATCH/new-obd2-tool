cmake_minimum_required(VERSION 3.14)
project(obd2_diagnostics_tool)

# Cross-platform and ARM support
if(CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64|aarch64")
    message(STATUS "Building for ARM64 architecture") 
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8-a")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configure build type
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Release" CACHE
      STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Define sources
set(SOURCES
  "runner/flutter_window.cpp"
  "runner/main.cpp"
  "runner/utils.cpp"
  "runner/win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Create executable
add_executable(${CMAKE_PROJECT_NAME} WIN32 ${SOURCES})

# Configure target properties
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
)

# Configure includes and linking
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}"
)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE 
  flutter 
  flutter_wrapper_app
  # Windows-specific libraries for OBD-II communication
  setupapi
  winusb
  bthprops
)

# Configure Flutter
flutter_application(${CMAKE_PROJECT_NAME})

# Install
install(TARGETS ${CMAKE_PROJECT_NAME}
  BUNDLE DESTINATION .
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)