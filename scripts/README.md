# Scripts Directory

This directory contains utility scripts for managing the OBD-II Diagnostics Tool project.

## Scripts Overview

### `setup_dev.sh`
**Purpose**: Initial development environment setup for new contributors
**Usage**: `./scripts/setup_dev.sh`

**What it does**:
- Checks Flutter installation and version
- Runs Flutter doctor to verify setup
- Installs project dependencies
- Verifies project setup with analysis and tests
- Provides platform-specific setup instructions

**When to use**: First time setting up the project for development

### `update_deps.sh`
**Purpose**: Safely manage and update project dependencies
**Usage**: `./scripts/update_deps.sh [command] [options]`

**Available commands**:
- `check` - Check for outdated dependencies
- `update [type]` - Update dependencies (patch|minor|major)
- `add <package>` - Add a new dependency
- `add-dev <package>` - Add a development dependency
- `remove <package>` - Remove a dependency
- `interactive` - Interactive update workflow
- `test` - Run tests after dependency changes
- `audit` - Check for security vulnerabilities
- `report` - Generate dependency report
- `clean` - Clean and reinstall dependencies

**When to use**: Regular dependency maintenance and updates

### `check_dep.sh`
**Purpose**: Analyze and validate dependencies
**Usage**: `./scripts/check_dep.sh [command] [package_name]`

**Available commands**:
- `check <package>` - Check specific dependency information
- `validate` - Validate pubspec.yaml format
- `unused` - Check for potentially unused dependencies
- `security` - Perform basic security checks
- `summary` - Generate dependency summary
- `all` - Run comprehensive dependency analysis

**When to use**: Dependency analysis and troubleshooting

## Requirements

All scripts require:
- **Flutter SDK 3.0.0+** installed and in PATH
- **Bash shell** (available on macOS, Linux, Windows with Git Bash/WSL)
- **Project root directory** (where pubspec.yaml is located)

## Examples

### Setting up for the first time
```bash
# Clone the project
git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
cd new-obd2-tool

# Run setup script
./scripts/setup_dev.sh
```

### Regular dependency maintenance
```bash
# Check for outdated dependencies
./scripts/update_deps.sh check

# Interactive update process
./scripts/update_deps.sh interactive

# Add a new dependency
./scripts/update_deps.sh add http

# Remove unused dependency
./scripts/update_deps.sh remove old_package
```

### Dependency analysis
```bash
# Check specific dependency
./scripts/check_dep.sh check flutter_bluetooth_serial

# Run comprehensive analysis
./scripts/check_dep.sh all

# Validate pubspec.yaml
./scripts/check_dep.sh validate
```

## Script Features

### Safety Features
- **Automatic backups** before making changes
- **Rollback capability** if updates fail
- **Test validation** after dependency changes
- **Incremental updates** to minimize risk

### Platform Support
- **Cross-platform** Bash scripts
- **Platform detection** for relevant features
- **Proper error handling** and user feedback
- **Colored output** for better readability

### Integration
- **Git integration** for tracking changes
- **CI/CD friendly** for automated workflows
- **Flutter ecosystem** best practices
- **Security considerations** built-in

## Troubleshooting

### Common Issues

#### "Flutter not found" error
```bash
# Check Flutter installation
which flutter
flutter --version

# Add Flutter to PATH (example for macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"
```

#### "Permission denied" error
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

#### Script doesn't work on Windows
- Use **Git Bash**, **WSL**, or **PowerShell** with Bash support
- Alternatively, run commands manually following the script logic

### Getting Help

1. **Script help**: Run any script with `help` argument
2. **Project documentation**: See [DEPENDENCIES.md](../DEPENDENCIES.md)
3. **Flutter documentation**: https://docs.flutter.dev/
4. **Community support**: GitHub Issues

## Contributing to Scripts

When modifying or adding scripts:

1. **Follow Bash best practices**
2. **Add error handling** and validation
3. **Include help documentation**
4. **Test on multiple platforms**
5. **Update this README** with changes

### Script Guidelines
- Use `set -e` for error handling
- Provide colored output with log functions
- Include usage information
- Add input validation
- Test script syntax with `bash -n script.sh`

---

For more information about the project's dependency management, see [DEPENDENCIES.md](../DEPENDENCIES.md).