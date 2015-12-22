# Science Builder

This is a super-project for MPQC,
[TiledArray](https://github.com/ValeevGroup/tiledarray),
[MADNESS](https://github.com/m-a-d-n-e-s-s/madness), and
[Elmental](http://libelemental.org). It simplifies the process of installing
these packages, and select dependencies, on your system. When one or more of 
these pacakges is enabled, the configure script searches for the packages. If a 
package is not found, it will be automatically be download, configure, built,
and optionally installed.

# Using SciBuilder

## Configure Packages:

Top level pac

```
$ cmake 
  -D ENABLE_(MPQC|TILEARRAY|MADNEES|ELEMENTAL)=(ON|OFF)
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_ROOT_DIR=<package install prefix>
  -D DEV_(MPQC|TILEARRAY|MADNEES|ELEMENTAL)=(ON|OFF)
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_URL=<source download url>
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_TAG=<Git branch name, commit id, or tag>
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_SOURCE_DIR=<package install path>
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_BUILD_DIR=<package build path>
  -D (MPQC|TILEARRAY|MADNEES|ELEMENTAL)_INSTALL_PREFIX=<package install path>
```

* `ENABLE_<package>` Search for the package. If the package is not found, it 
will be downloaded, configured, built, and installed. The default for all 
pacakges is `OFF`.
* `<package>_ROOT_DIR` The installation prefix for package. This path is
searched for existing installations of `<package>`.  
* `DEV_<package>` Enable developer mode for the given package, which disables
the installation step for the package. When developer mode is enabled, it is
recommended that you specify the `<package>_SOURCE_DIR` and 
`<package>_BUILD_DIR` to setup the working directories for your development 
project.
* `<package>_SOURCE_DIR` Specifies the path to the package source directory.
The default path is `${CMAKE_BINARY_DIR}/<package>/source`.
* `<package>_BUILD_DIR` Specifies the path to the package source directory.
The default path is `${CMAKE_BINARY_DIR}/<package>/build`.
* `<package>_INSTALL_PREFIX` Specifies the path to the package source directory.
The default path is `${CMAKE_INSTALL_PREFIX}`.

**NOTE** Required package dependencies are automatically enabled. For example,
if `ENABLE_TILEDARRAY` is `ON`, `ENABLE_MADNESS` will also be set to `ON` but
`ENABLE_ELEMENTAL` will be `OFF` since it is an optional dependency for 
TiledArray.

## Install CMake

SciBuilder includes a make file that automates downloading and building a recent
version of CMake. To build and install cmake from the SciBuilder source 
directory:
```
$ cd cmake
$ make -j PREFIX=/path/to/install/cmake
```
