# - Try to find Eigen3
# Input variables:
#  EIGEN_ROOT_DIR     - The Eigen install directory
#  EIGEN_INCLUDE_DIR  - The Eigen include directory
#  EIGEN_LIBRARY      - The Eigen library directory
# Output variables:
#  EIGEN_FOUND        - System has Eigen
#  EIGEN_INCLUDE_DIRS - The Eigen include directories
#  EIGEN_LIBRARIES    - The libraries needed to use Eigen
#  EIGEN_VERSION      - The version string for Eigen

include(FindPackageHandleStandardArgs)
  
if(NOT EIGEN_FOUND)

  # Set default sarch paths for Eigen
  if(EIGEN_ROOT_DIR)
    set(EIGEN_INCLUDE_DIR ${EIGEN_ROOT_DIR}/include CACHE PATH "The include directory for Eigen")
  endif()
  
  find_path(EIGEN_INCLUDE_DIRS NAMES signature_of_eigen3_matrix_library
      HINTS ${EIGEN_INCLUDE_DIR}
      PATH_SUFFIXES eigen3 eigen)
  
  # Get Eigen version
  if(EIGEN_INCLUDE_DIRS)
    file(READ "${EIGEN_INCLUDE_DIR}/Eigen/src/Core/util/Macros.h" _eigen3_version_header)

    string(REGEX REPLACE ".*define[ \t]+EIGEN_WORLD_VERSION[ \t]+([0-9]+).*" "\\1" 
        EIGEN_MAJOR_VERSION "${_eigen3_version_header}")
    string(REGEX REPLACE ".*define[ \t]+EIGEN_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" 
        EIGEN_MINOR_VERSION "${_eigen3_version_header}")
    string(REGEX REPLACE ".*define[ \t]+EIGEN_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" 
        EIGEN_MICRO_VERSION "${_eigen3_version_header}")
    set(EIGEN_VERSION "${EIGEN_MAJOR_VERSION}.${EIGEN_MINOR_VERSION}.${EIGEN_MICRO_VERSION}")
    unset(_eigen3_version_header)
  endif()

  # handle the QUIETLY and REQUIRED arguments and set EIGEN_FOUND to TRUE
  # if all listed variables are TRUE
  find_package_handle_standard_args(Eigen
      FOUND_VAR EIGEN_FOUND
      VERSION_VAR EIGEN_VERSION 
      REQUIRED_VARS EIGEN_INCLUDE_DIRS)

  mark_as_advanced(EIGEN_INCLUDE_DIR EIGEN_INCLUDE_DIRS)

endif()
