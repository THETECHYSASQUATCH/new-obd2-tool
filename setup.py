from setuptools import setup, find_packages

setup(
    name="obd2-diagnostics-tool",
    version="1.0.0",
    description="Advanced OBD-II Diagnostics and Programming Tool",
    author="THETECHYSASQUATCH",
    packages=find_packages(),
    install_requires=[
        "pyserial>=3.5",
        "numpy>=1.21.0",
        "matplotlib>=3.5.0",
        "requests>=2.28.0",
        "pyyaml>=6.0",
    ],
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "obd2-tool=main:main",
        ],
    },
)