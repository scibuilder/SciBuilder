# -*- mode: cmake -*-

# Check for Eigen
if(ENABLE_EIGEN)
  find_package(Eigen 3.0)
endif()

if(EIGEN_FOUND)

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

elseif(ENABLE_EIGEN)

  # Create a cache entry for Eigen build variables.
  # Note: This will not overwrite user specified values.
  set(EIGEN_SOURCE_DIR "${PROJECT_BINARY_DIR}/eigen/source/" CACHE PATH 
      "Path to the Eigen source directory")
  set(EIGEN_BINARY_DIR "${PROJECT_BINARY_DIR}/eigen/build/" CACHE PATH 
      "Path to the Eigen build directory")
  set(EIGEN_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
      "Path to install Eigen")
  set(EIGEN_URL "https://bitbucket.org/eigen/eigen" CACHE STRING 
      "Path to the Eigen repository")
  set(EIGEN_TAG "3.2.4" CACHE STRING "The Eigen revision tag")

  message("** Will build Eigen from ${EIGEN_URL}")

  ExternalProject_Add(eigen3
      PREFIX ${CMAKE_INSTALL_PREFIX}
      STAMP_DIR ${CMAKE_BINARY_DIR}/stamp
     #--Download step--------------
      HG_REPOSITORY ${EIGEN_URL}
      HG_TAG ${EIGEN_TAG}
     #--Configure step-------------
      SOURCE_DIR ${EIGEN_SOURCE_DIR}
      CMAKE_ARGS
          -DCMAKE_INSTALL_PREFIX:path=${EIGEN_INSTALL_PREFIX}
     #--Build step-----------------
      BINARY_DIR ${EIGEN_BINARY_DIR}       # Specify build dir location
     #--Install step---------------
      INSTALL_DIR ${EIGEN_INSTALL_PREFIX} # Installation prefix
     #--Custom targets-------------
    )

  set(EIGEN_INCLUDE_DIR ${EIGEN_INSTALL_PREFIX}/include/eigen3)
  
  # Add Eigen3 as a dependenecy to consuming projects.
  list(APPEND TILEDARRAY_DEPENDS eigen3)

endif()
