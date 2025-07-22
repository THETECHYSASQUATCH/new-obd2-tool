#!/usr/bin/env python3
"""
Build script for the OBD-II Diagnostics and Programming Tool
"""

import os
import sys
import subprocess
import shutil
import argparse
from pathlib import Path


def run_command(command, check=True, shell=False):
    """Run a shell command and return the result."""
    try:
        print(f"Running: {' '.join(command) if isinstance(command, list) else command}")
        result = subprocess.run(
            command,
            check=check,
            shell=shell,
            capture_output=True,
            text=True
        )
        if result.stdout:
            print(result.stdout)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
        if e.stderr:
            print(f"Error output: {e.stderr}")
        if check:
            sys.exit(1)
        return e


def check_python_version():
    """Check if Python version is sufficient."""
    if sys.version_info < (3, 8):
        print("Error: Python 3.8 or higher is required")
        sys.exit(1)
    print(f"Python version: {sys.version}")


def install_dependencies():
    """Install project dependencies."""
    print("Installing dependencies...")
    
    # Install main dependencies
    run_command([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    
    # Install development dependencies
    run_command([sys.executable, "-m", "pip", "install", "-e", "."])


def run_tests():
    """Run the test suite."""
    print("Running tests...")
    
    # Run pytest if available, otherwise use unittest
    try:
        run_command([sys.executable, "-m", "pytest", "tests/", "-v"])
    except:
        print("pytest not found, using unittest...")
        run_command([sys.executable, "-m", "unittest", "discover", "tests", "-v"])


def run_linting():
    """Run code linting."""
    print("Running linting...")
    
    # Try to run flake8 if available
    try:
        run_command([sys.executable, "-m", "flake8", "src/", "--max-line-length=120"], check=False)
    except:
        print("flake8 not available, skipping linting")


def build_executable():
    """Build standalone executable using PyInstaller."""
    print("Building executable...")
    
    try:
        # Install PyInstaller if not available
        run_command([sys.executable, "-m", "pip", "install", "pyinstaller"], check=False)
        
        # Build executable
        run_command([
            sys.executable, "-m", "PyInstaller",
            "--onefile",
            "--windowed",
            "--name", "obd2-tool",
            "--add-data", "src:src",
            "main.py"
        ])
        
        print("Executable built successfully in dist/ directory")
        
    except Exception as e:
        print(f"Error building executable: {e}")
        print("PyInstaller build failed, but the application can still be run with Python")


def create_package():
    """Create distribution package."""
    print("Creating distribution package...")
    
    # Clean previous builds
    shutil.rmtree("build", ignore_errors=True)
    shutil.rmtree("dist", ignore_errors=True)
    
    # Build source distribution
    run_command([sys.executable, "setup.py", "sdist"])
    
    # Build wheel distribution
    run_command([sys.executable, "setup.py", "bdist_wheel"])
    
    print("Distribution packages created in dist/ directory")


def clean_build():
    """Clean build artifacts."""
    print("Cleaning build artifacts...")
    
    directories_to_clean = [
        "build",
        "dist", 
        "*.egg-info",
        "__pycache__",
        ".pytest_cache",
        ".coverage"
    ]
    
    for pattern in directories_to_clean:
        for path in Path(".").rglob(pattern):
            if path.is_dir():
                shutil.rmtree(path, ignore_errors=True)
                print(f"Removed directory: {path}")
            elif path.is_file():
                path.unlink()
                print(f"Removed file: {path}")


def setup_development():
    """Set up development environment."""
    print("Setting up development environment...")
    
    # Create virtual environment if it doesn't exist
    venv_path = Path("venv")
    if not venv_path.exists():
        print("Creating virtual environment...")
        run_command([sys.executable, "-m", "venv", "venv"])
    
    # Install dependencies
    install_dependencies()
    
    print("Development environment setup complete!")
    print("To activate the virtual environment, run:")
    if os.name == 'nt':
        print("  venv\\Scripts\\activate")
    else:
        print("  source venv/bin/activate")


def main():
    """Main build script entry point."""
    parser = argparse.ArgumentParser(description="Build script for OBD-II Tool")
    parser.add_argument("--test", action="store_true", help="Run tests")
    parser.add_argument("--lint", action="store_true", help="Run linting")
    parser.add_argument("--build", action="store_true", help="Build executable")
    parser.add_argument("--package", action="store_true", help="Create distribution package")
    parser.add_argument("--clean", action="store_true", help="Clean build artifacts")
    parser.add_argument("--dev", action="store_true", help="Set up development environment")
    parser.add_argument("--all", action="store_true", help="Run all build steps")
    
    args = parser.parse_args()
    
    # Change to script directory
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    print("OBD-II Diagnostics and Programming Tool - Build Script")
    print("=" * 60)
    
    # Check Python version
    check_python_version()
    
    if args.clean:
        clean_build()
    
    if args.dev:
        setup_development()
    
    if args.all or (not any(vars(args).values())):
        # Default: install dependencies and run tests
        install_dependencies()
        run_tests()
        run_linting()
    
    if args.test:
        run_tests()
    
    if args.lint:
        run_linting()
    
    if args.build:
        build_executable()
    
    if args.package:
        create_package()
    
    print("\nBuild script completed!")


if __name__ == "__main__":
    main()