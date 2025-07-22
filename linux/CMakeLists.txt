cmake_minimum_required(VERSION 3.18)
project(obd2_diagnostics_tool LANGUAGES CXX)

set(BINARY_NAME "obd2_diagnostics_tool")

# Configure build
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# System-level dependencies
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

# Application build
set(SOURCES
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Build executable
add_executable(${BINARY_NAME} ${SOURCES})

# Configure dependencies
target_link_libraries(${BINARY_NAME} PRIVATE 
  flutter
  PkgConfig::GTK
  PkgConfig::GLIB
  PkgConfig::GIO
)

# Configure includes
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Cross-platform compatibility
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    message(STATUS "Building for ARM64 architecture")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    message(STATUS "Building for ARM architecture") 
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a")
endif()

# Install
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# Flutter target platform
flutter_application(${BINARY_NAME})