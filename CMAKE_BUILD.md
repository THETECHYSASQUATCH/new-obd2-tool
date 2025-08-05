# CMake Build Instructions

This repository includes a CMake configuration for building C++ components of the OBD2 tool.

## Requirements

- CMake 3.15 or higher
- C++17 compatible compiler
- Visual Studio 2019 or higher (Windows)

## Building

### Windows (Visual Studio)

1. Open Visual Studio Developer Command Prompt
2. Navigate to the repository root
3. Create and configure build directory:
   ```bash
   mkdir build
   cd build
   cmake .. -G "Visual Studio 16 2019" -A x64
   ```
4. Build the project:
   ```bash
   cmake --build . --config Release
   ```

### Cross-platform

```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

## Features

- **C++17 Standard**: Modern C++ features enabled
- **Unicode Support**: Enabled for Windows builds
- **Recursive File Collection**: Automatically finds all source files in src/
- **Proper Output Directories**: Organized bin/ and lib/ directories
- **Visual Studio Integration**: Optimized for Visual Studio Enterprise
- **Installation Rules**: Supports `make install` or `cmake --install`
- **Cross-platform**: Works on Windows, Linux, and macOS

## Project Structure

```
src/
├── main.cpp          # Main application entry point
└── utils/
    ├── helper.h       # Utility header files
    └── helper.cpp     # Utility implementation
```

## Installation

```bash
cmake --install . --prefix /path/to/install
```

The executable will be installed to `<prefix>/bin/new_obd2_tool_cpp`.

## Development

This CMake configuration is designed to work alongside the existing Flutter build system. It provides a separate build path for any C++ components that may be added to the project.

The configuration includes:
- Warning flags for better code quality
- Platform-specific optimizations
- Future-ready library linking setup
- Debug and Release build configurations