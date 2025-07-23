# OBD2.Core - .NET Library

This directory contains the .NET Core library component for the OBD-II Diagnostics Tool. This library provides core functionality for OBD-II communication, data processing, and protocol handling that can be used by .NET applications or integrated with the Flutter app through platform channels.

## Features

- **OBD-II Protocol Support**: Handle various OBD-II protocols and communication standards
- **Serial Communication**: Direct serial port communication with OBD-II adapters
- **Data Processing**: Parse and process diagnostic data from vehicles
- **Configuration Management**: Handle settings and device configurations
- **Logging**: Comprehensive logging for debugging and monitoring
- **Cross-Platform**: Built on .NET 8.0 for cross-platform compatibility

## Dependencies

This project uses several NuGet packages for functionality:

- **Microsoft.Extensions.*** - For dependency injection, logging, and configuration
- **System.IO.Ports** - For serial communication with OBD-II adapters
- **System.Text.Json** & **Newtonsoft.Json** - For data serialization
- **NUnit** & **Moq** - For unit testing
- **Microsoft.Extensions.Http** - For HTTP-based OBD-II adapters

## Getting Started

### Prerequisites

- .NET 8.0 SDK or later
- Compatible with Windows, macOS, and Linux

### Building the Library

```bash
# Navigate to the dotnet directory
cd dotnet

# Restore NuGet packages
dotnet restore

# Build the library
dotnet build

# Run tests (when implemented)
dotnet test

# Create NuGet package
dotnet pack
```

### Using in Your Project

```xml
<PackageReference Include="OBD2.Core" Version="1.0.0" />
```

## Integration with Flutter

This .NET library can be integrated with the Flutter application through:

1. **Platform Channels**: Create platform-specific implementations that use this library
2. **Shared Data Models**: Use consistent data structures between .NET and Dart
3. **Background Services**: Run intensive OBD-II processing in .NET while maintaining UI in Flutter

## Configuration

The library uses the `NuGet.config` file in the repository root for package management. This ensures consistent package sources and security settings across the project.

## Contributing

When contributing to the .NET component:

1. Follow .NET coding standards and conventions
2. Add unit tests for new functionality
3. Update documentation for API changes
4. Ensure cross-platform compatibility

## License

This component is part of the OBD-II Diagnostics Tool project and follows the same MIT license.