cmake_minimum_required(VERSION 3.14)
project(obd2_diagnostics_tool LANGUAGES CXX)

# Arch-specific definitions
if(CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64|aarch64")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
    message(STATUS "Building for Apple Silicon (ARM64)")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    set(CMAKE_OSX_ARCHITECTURES "x86_64")
    message(STATUS "Building for Intel (x86_64)")
else()
    # Universal binary for maximum compatibility
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
    message(STATUS "Building Universal Binary (ARM64 + x86_64)")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(PRODUCT_BUNDLE_IDENTIFIER "com.example.obd2DiagnosticsTool")

# Define the application target
add_executable(${CMAKE_PROJECT_NAME}
  "Runner/main.m"
  "Runner/AppDelegate.m"
)

# Configure target properties
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
  BUNDLE True
  MACOSX_BUNDLE_GUI_IDENTIFIER ${PRODUCT_BUNDLE_IDENTIFIER}
  MACOSX_BUNDLE_BUNDLE_NAME ${CMAKE_PROJECT_NAME}
  MACOSX_BUNDLE_DISPLAY_NAME "OBD-II Diagnostics Tool"
  MACOSX_BUNDLE_INFO_STRING "Cross-platform OBD-II diagnostic tool"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
  MACOSX_BUNDLE_BUNDLE_VERSION "1"
  MACOSX_BUNDLE_COPYRIGHT "© 2025 OBD-II Diagnostics Tool"
  MACOSX_DEPLOYMENT_TARGET 10.14
)

# Link Flutter
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
  "-framework Cocoa"
  "-framework IOBluetooth"
  "-framework CoreBluetooth" 
  "-framework IOKit"
  "-framework CoreFoundation"
)

# Include Flutter
flutter_application(${CMAKE_PROJECT_NAME})