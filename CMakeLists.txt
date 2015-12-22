#; -*-CMake-*-

#
#  This file is a part of SciBuilder.
#  Copyright (C) 2015  Virginia Tech
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Justus Calvin
#  Department of Chemistry, Virginia Tech
#
#  CMakeLists.txt
#  Dec 12, 2015
#

cmake_minimum_required (VERSION 3.0.0)
project(SciBuilder)

# extra cmake files are shipped with SciBuilder
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules/)

# Include modules ==============================================================

include(CMakeDependentOption)
include(ExternalProject)
include(CheckCXXSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)


# Add common options ===========================================================

option(ENABLE_MPI "Enable Message Passing Interface (MPI) Library" ON)
add_feature_info(MPI ENABLE_MPI "Message Passing Interface")

# Add option for MPQC ==========================================================

option(ENABLE_MPQC "Enable the MPQC project" OFF)
add_feature_info(MPQC ENABLE_MPQC "A massively-parallel, block-sparse tensor framework")
cmake_dependent_option(DEV_MPQC "Enable developer mode for MPQC" OFF
    "ENABLE_MPQC" OFF)

# Add options for TiledArray ===================================================

option(ENABLE_TILEDARRAY "Enable the TiledArray project" ${ENABLE_MPQC})
add_feature_info(TiledArray ENABLE_TILEDARRAY "A massively-parallel, block-sparse tensor framework")
cmake_dependent_option(DEV_TILEDARRAY "Enable developer mode for TiledArray" OFF
    "ENABLE_TILEDARRAY" OFF)
cmake_dependent_option(ENABLE_TILEDARRAY_UNITTESTS "Enable TiledArray unit test build" OFF
    "ENABLE_TILEDARRAY" OFF)
cmake_dependent_option(ENABLE_BOOST "Enable build for Boost" ON
    "ENABLE_TILEDARRAY_UNITTESTS" OFF)
add_feature_info(Boost ENABLE_BOOST "Boost provides free peer-reviewed portable C++ source libraries.")
cmake_dependent_option(ENABLE_EIGEN 
    "Build Eigen library if it is not found on the system" ON
    "ENABLE_TILEDARRAY" OFF)
add_feature_info(Eigen ENABLE_EIGEN "Eigen is a C++ template library for linear algebra.")
cmake_dependent_option(ENABLE_MINIMUAL_MADNESS "Build only world library for MADNESS" ON
    "NOT DEFINED ENABLE_MADNESS;ENABLE_TILEDARRAY" OFF)

# Add options for MADNESS ======================================================

option(ENABLE_MADNESS "Enable build for the MADNESS project" ${ENABLE_TILEDARRAY})
add_feature_info(MADNESS ENABLE_MADNESS "Multiresolution Adaptive Numerical Environment for Scientific Simulation")
cmake_dependent_option(DEV_MADNESS "Enable developer mode for MADNESS" OFF
    "ENABLE_MADNESS" OFF)
set(FORTRAN_INTEGER_SIZE 4 CACHE STRING "The fortran integer size (4 or 8 bytes) used for BLAS and LAPACK function calls")
if(NOT (FORTRAN_INTEGER_SIZE EQUAL 4 OR FORTRAN_INTEGER_SIZE EQUAL 8))
  message(FATAL_ERROR "Incorrect fortran integer size '${FORTRAN_INTEGER_SIZE}'\n"
                       "FORTRAN_INTEGER_SIZE must be equal to 4 or 8")
endif()
cmake_dependent_option(ENABLE_TBB "Enable build for TBB library" ON 
    "ENABLE_MADNESS" OFF)
cmake_dependent_option(ENABLE_LIBXC "Enable build for Libxc library" ON 
    "ENABLE_MADNESS" OFF)


# Add options for Elemental ====================================================

option(ENABLE_ELEMENTAL "Enable build for the Elemental project" OFF)
add_feature_info(Elemental ENABLE_ELEMENTAL "Elemental provides parallel linear algebra")
cmake_dependent_option(DEV_ELEMENTAL "Enable developer mode for Elemental" OFF
    "ENABLE_ELEMENTAL" OFF)


# Enable support for shared libraries ==========================================

get_property(SUPPORTS_SHARED GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS)
cmake_dependent_option(BUILD_SHARED_LIBS "Enable shared libraries" ON
      "SUPPORTS_SHARED" OFF)
if(BUILD_SHARED_LIBS)
  set(ENABLE_SHARED "--enable-shared")
  set(ENABLE_STATIC "--disable-static")
else()
  set(ENABLE_SHARED "--disable-shared")
  set(ENABLE_STATIC "--enable-static")
endif()


# Set standard compile variables ===============================================

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
  set(CXXFLAGS "${CMAKE_CXX_COMPILE_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_DEBUG}")
  set(LDFLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_DEBUG}")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
  set(CXXFLAGS "${CMAKE_CXX_COMPILE_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_RELEASE}")
  set(LDFLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_RELEASE}")
elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  set(CXXFLAGS "${CMAKE_CXX_COMPILE_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_RELWITHDEBINFO}")
  set(LDFLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_RELWITHDEBINFO}")
elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
  set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_MINSIZEREL}")
  set(CXXFLAGS "${CMAKE_CXX_COMPILE_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_MINSIZEREL}")
  set(LDFLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_FLAGS_MINSIZEREL}")
endif()

string(STRIP "${CFLAGS}" CFLAGS)
string(STRIP "${CXXFLAGS}" CXXFLAGS)
string(STRIP "${LDFLAGS}" LDFLAGS)


# Check for dependencies =======================================================

# Check for and build packages
include(lapack.cmake)
include(mpi.cmake)
include(boost.cmake)
include(eigen.cmake)
#include(gperftools.cmake)
include(tbb.cmake)
include(libxc.cmake)

# Build target projects ========================================================

#include(elemental.cmake)
include(madness.cmake)
#include(tiledarray.cmake)
#include(mpqc.cmake)


feature_summary(WHAT ALL
                DESCRIPTION "=== SciBuilder Package/Feature Info ===")
