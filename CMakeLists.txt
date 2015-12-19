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

# Add build options ============================================================

# Add option for MPQC
option(ENABLE_MPQC "Enable build for the MPQC project" OFF)
add_feature_info(MPQC ENABLE_MPQC "A massively-parallel, block-sparse tensor framework")

# Add options for TiledArray
option(ENABLE_TILEDARRAY "Enable build for the TiledArray project" ${ENABLE_MPQC})
add_feature_info(TiledArray ENABLE_TILEDARRAY "A massively-parallel, block-sparse tensor framework")
cmake_dependent_option(ENABLE_TILEDARRAY_UNITTESTS "Enable TiledArray unit test build" OFF
    "ENABLE_TILEDARRAY" OFF)

# Add options for MADNESS
option(ENABLE_MADNESS "Enable build for the MADNESS project" ${ENABLE_TILEDARRAY})
add_feature_info(MADNESS ENABLE_MADNESS "Multiresolution Adaptive Numerical Environment for Scientific Simulation")

# Add options for Elemental
option(ENABLE_ELEMENTAL "Enable build for the Elemental project" OFF)
add_feature_info(Elemental ENABLE_ELEMENTAL "Elemental provides parallel linear algebra")
    
# Add common options


# Enable support for shared libraries ==========================================

get_property(SUPPORTS_SHARED GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS)
cmake_dependent_option(BUILD_SHARED_LIBS "Enable shared libraries" ON
      "SUPPORTS_SHARED" OFF)


# Check for and build packages
include(lapack.cmake)
include(boost.cmake)
include(eigen.cmake)
#include(mpi.cmake)
#include(gperftools.cmake)
#include(tbb.cmake)
# Build target projects
#include(elemental.cmake)
#include(madness.cmake)
#include(tiledarray.cmake)
#include(mpqc.cmake)


feature_summary(WHAT ALL
                DESCRIPTION "=== SciBuilder Package/Feature Info ===")
