# GNU Privacy Guard (GPG) Build Instructions

This directory contains build scripts and documentation for compiling GNU Privacy Guard (GPG) from source on Linux systems.

## Prerequisites

### System Requirements
- Linux distribution (Ubuntu, Debian, CentOS, RHEL, etc.)
- At least 1GB of free disk space
- Internet connection for downloading source code
- Root/sudo access for installing dependencies

### Required Packages

For **Debian/Ubuntu** systems, install the following packages:

```bash
sudo apt-get update
sudo apt-get install build-essential autoconf automake libtool pkg-config \
    libgpg-error-dev libgcrypt-dev libassuan-dev libksba-dev libnpth-dev \
    wget bzip2 gettext texinfo
```

For **CentOS/RHEL/Fedora** systems:

```bash
# CentOS/RHEL 7/8
sudo yum install gcc make autoconf automake libtool pkgconfig \
    libgpg-error-devel libgcrypt-devel libassuan-devel libksba-devel \
    npth-devel wget bzip2 gettext texinfo

# Fedora
sudo dnf install gcc make autoconf automake libtool pkgconfig \
    libgpg-error-devel libgcrypt-devel libassuan-devel libksba-devel \
    npth-devel wget bzip2 gettext texinfo
```

For **Arch Linux**:

```bash
sudo pacman -S base-devel autoconf automake libtool pkg-config \
    libgpg-error libgcrypt libassuan libksba npth wget bzip2 gettext texinfo
```

See `gpg-dependencies.txt` for a complete list of required packages.

## Quick Start

### 1. Check Dependencies
Before building, verify that all required dependencies are installed:

```bash
./gpg-build.sh check-deps
```

### 2. Build GPG
Run the automated build script:

```bash
./gpg-build.sh build
```

This will:
- Download the GPG source code
- Configure the build with appropriate options
- Compile GPG using all available CPU cores
- Install GPG to a local `build/` directory
- Run basic tests
- Create an environment setup script

### 3. Use the Built GPG
After successful build, source the environment script:

```bash
source build/gpg-env.sh
gpg --version
```

## Build Configuration

### Default Settings
- **Installation prefix**: `./build/usr/local/`
- **GPG version**: 2.4.3 (configurable in script)
- **Build type**: Release build with maintainer mode
- **Features enabled**: GPG, GPGSM, GPG-Agent, Dirmngr, GPGtar, WKS tools

### Customizing the Build

#### Changing Installation Directory
Edit the `PREFIX` variable in `gpg-build.sh`:

```bash
PREFIX="/your/custom/path"
```

#### Building Different GPG Version
Edit the `GPG_VERSION` variable in `gpg-build.sh`:

```bash
GPG_VERSION="2.4.4"  # or your desired version
```

#### Custom Configure Options
Modify the `configure_gpg()` function in `gpg-build.sh` to add or remove configure options:

```bash
./configure \
    --prefix="$PREFIX" \
    --your-custom-options \
    --enable-feature \
    --disable-unwanted-feature
```

## Build Script Options

### Available Commands
```bash
./gpg-build.sh build      # Full build process (default)
./gpg-build.sh clean      # Clean build artifacts
./gpg-build.sh check-deps # Check build dependencies only
```

### Build Process Details

1. **Dependency Check**: Verifies all required tools and libraries are installed
2. **Source Download**: Downloads and extracts GPG source code from gnupg.org
3. **Configuration**: Runs autogen.sh (if present) and configure with optimal settings
4. **Compilation**: Builds GPG using parallel compilation
5. **Installation**: Installs to local build directory (no system-wide installation)
6. **Testing**: Runs the GPG test suite
7. **Environment Setup**: Creates convenience scripts for using the built GPG

## Troubleshooting

### Common Issues

#### Missing Dependencies
```
Error: Missing dependencies: gcc autoconf libgcrypt-dev
```
**Solution**: Install the missing packages using your system's package manager.

#### Download Failures
```
Error: Cannot download source
```
**Solution**: Check internet connection and firewall settings. The script tries both `wget` and `curl`.

#### Configuration Failures
```
Error: configure failed
```
**Solution**: 
- Ensure all development packages are installed
- Check that autotools are properly installed
- Review the config.log file in the source directory

#### Build Failures
```
Error: make failed
```
**Solution**: 
- Check available disk space (need ~1GB)
- Ensure all dependencies are satisfied
- Try building with fewer parallel jobs: edit the script to use `make -j1`

#### Test Failures
```
Warning: Some tests failed
```
**Note**: Test failures don't necessarily mean GPG won't work. The built binaries should still be functional.

### Checking Build Results
After a successful build, verify the installation:

```bash
source build/gpg-env.sh
gpg --version
gpg --help
```

## Advanced Usage

### Building with Custom Libraries
If you need to link against custom versions of the GPG libraries, set the PKG_CONFIG_PATH:

```bash
export PKG_CONFIG_PATH="/path/to/custom/libs/pkgconfig:$PKG_CONFIG_PATH"
./gpg-build.sh build
```

### Cross-Compilation
For cross-compilation, modify the configure command in the script:

```bash
./configure \
    --host=arm-linux-gnueabihf \
    --prefix="$PREFIX" \
    # ... other options
```

### Static Linking
For a statically linked GPG, add to configure options:

```bash
./configure \
    --enable-static \
    --disable-shared \
    --prefix="$PREFIX" \
    # ... other options
```

## File Structure

After a successful build, the directory structure will be:

```
build/
├── usr/local/
│   ├── bin/          # GPG binaries (gpg, gpg-agent, etc.)
│   ├── lib/          # Libraries
│   ├── share/        # Documentation and locale files
│   └── ...
├── gpg-env.sh        # Environment setup script
└── ...
```

## Security Considerations

- The build process downloads source code from the internet
- Always verify the GPG signatures of downloaded source code in production environments
- The built GPG is installed locally and doesn't affect system-wide GPG installation
- Consider building in an isolated environment (container, VM) for production use

## Contributing

If you encounter issues with the build process or have improvements:

1. Check existing issues in the repository
2. Provide detailed error messages and system information
3. Test your changes on multiple Linux distributions
4. Follow the existing code style in the build script

## License

The build scripts are provided under the same license as the main project. GNU Privacy Guard itself is licensed under the GNU General Public License v3+.

## References

- [GNU Privacy Guard Official Website](https://gnupg.org/)
- [GPG Build Instructions](https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG.html)
- [Autotools Documentation](https://www.gnu.org/software/autoconf/manual/)