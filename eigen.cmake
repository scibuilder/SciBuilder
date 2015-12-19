# -*- mode: cmake -*-


cmake_dependent_option(ENABLE_EIGEN 
    "Build Eigen library if it is not found on the system" ON
    "ENABLE_TILEDARRAY" OFF)
add_feature_info(Eigen ENABLE_EIGEN "Eigen is a C++ template library for linear algebra.")

# Check for Eigen
if(ENABLE_TILEDARRAY)
  # Limit scope of the search if EIGEN_ROOT or EIGEN_INCLUDEDIR is provided.
  if(EIGEN_ROOT OR EIGEN_INCLUDEDIR)
    set(Eigen_NO_SYSTEM_PATHS TRUE)
  endif()

  if(ENABLE_EIGEN)
    find_package(Eigen 3.0)
  else()
    find_package(Eigen 3.0 REQUIRED)
  end()
endif()

if(EIGEN_FOUND)

  # Create a cache entry for Eigen build variables.
  # Note: This will not overwrite user specified values.
  set(EIGEN_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}/eigen/" CACHE PATH 
        "Path to the Eigen download directory")
  set(EIGEN_SOURCE_DIR "${PROJECT_SOURCE_DIR}/eigen/source/" CACHE PATH 
        "Path to the Eigen source directory")
  set(EIGEN_BINARY_DIR "${PROJECT_BINARY_DIR}/eigen/build/" CACHE PATH 
        "Path to the Eigen build directory")
  set(EIGEN_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
  set(EIGEN_URL "https://bitbucket.org/eigen/eigen" CACHE STRING 
        "Path to the Eigen repository")
  set(EIGEN_TAG "3.2.4" CACHE STRING 
        "The Eigen revision tag")

  cmake_push_check_state()

  # Perform a compile check with Eigen
  list(APPEND CMAKE_REQUIRED_INCLUDES ${EIGEN_INCLUDE_DIR})
  CHECK_CXX_SOURCE_COMPILES("
    #include <Eigen/Core>
    #include <Eigen/Dense>
    #include <iostream>
    int main(int argc, char* argv[]){
      Eigen::MatrixXd m = Eigen::MatrixXd::Random(5, 5);
      m = m.transpose() + m;
      Eigen::SelfAdjointEigenSolver<Eigen::MatrixXd> eig(m);
      Eigen::MatrixXd m_invsqrt = eig.operatorInverseSqrt();
      std::cout << m_invsqrt << std::endl;
    }"
    EIGEN_COMPILES)
      
  cmake_pop_check_state()

  if (NOT EIGEN_COMPILES)
    message(FATAL_ERROR "Eigen found at ${EIGEN_ROOT}, but could not compile test program")
  endif()

elseif(ENABLE_BUILD_EIGEN)


  message("** Will build Eigen from ${EIGEN_URL}")

  ExternalProject_Add(eigen3
    PREFIX ${CMAKE_INSTALL_PREFIX}
   #--Download step--------------
    HG_REPOSITORY ${EIGEN_URL}
    HG_TAG ${EIGEN_TAG}
   #--Configure step-------------
    SOURCE_DIR ${EIGEN_SOURCE_DIR}
    CONFIGURE_COMMAND ""
   #--Build step-----------------
    BUILD_COMMAND ""
   #--Install step---------------
    INSTALL_COMMAND ""
   #--Custom targets-------------
    INSTALL_COMMAND "${CMAKE_COMMAND}" "-E" "copy_directory" "${EIGEN_SOURCE_DIR}/eigen3/" "${EIGEN_INSTALL_PREFIX}/include/eigen3/" "&&"
                    "${CMAKE_COMMAND}" "-E" "copy" "${EIGEN_SOURCE_DIR}/signature_of_eigen3_matrix_library" "${EIGEN_INSTALL_PREFIX}/include/eigen3/"
   #--Custom targets-------------
    STEP_TARGETS download
    )

  set(EIGEN_INCLUDE_DIR ${EIGEN_INSTALL_PREFIX}/include/eigen3)

endif()
