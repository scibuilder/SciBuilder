# Find BLAS and LAPACK.
include(CheckCFortranFunctionExists)
include(CMakePushCheckState)

option(ENABLE_MKL "Search for Intel Math Kernel Library (MKL) for BLAS and LAPACK support" ON)
option(ENABLE_ACML "Search for AMD Core Math Library (ACML) for BLAS and LAPACK support" ON)

set(FORTRAN_INTEGER_SIZE 4 CACHE STRING "The fortran integer size (4 or 8 bytes) used for BLAS and LAPACK function calls")
if(NOT (FORTRAN_INTEGER_SIZE EQUAL 4 OR FORTRAN_INTEGER_SIZE EQUAL 8))
  message(FATAL_ERROR "Incorrect fortran integer size '${FORTRAN_INTEGER_SIZE}'\n"
                       "FORTRAN_INTEGER_SIZE must be equal to 4 or 8")
endif()

if(NOT LAPACK_LIBRARIES)

  if(ENABLE_MKL)
    find_package(MKL)
    
    if(MKL_FOUND)
      set(LAPACK_FOUND TRUE)
      set(LAPACK_LIBRARIES ${MKL_LIBRARIES})
      set(HAVE_INTEL_MKL 1)
    endif()
  endif()
  
  if(ENABLE_ACML)
    find_package(ACML)
    
    if(ACML_FOUND)
      set(LAPACK_FOUND TRUE)
      set(LAPACK_LIBRARIES ${ACML_LIBRARIES})
      set(HAVE_ACML 1)
    endif()
  endif()
  
  # Search for system specific BLAS/LAPACK checks
  if(NOT LAPACK_FOUND AND CMAKE_SYSTEM_NAME MATCHES "Darwin")
    # Accelerate is always present, so no need to search
    set(LAPACK_LIBRARIES "-framework Accelerate")
    set(LAPACK_FOUND TRUE)
  endif()
  
  # Search for Netlib LAPACK and BLAS libraries
  if(NOT LAPACK_FOUND)
    find_library(LAPACK_lapack_LIBRARY lapack)
    find_library(LAPACK_blas_LIBRARY blas)
    
    if(LAPACK_lapack_LIBRARY AND LAPACK_blas_LIBRARY)
      set(LAPACK_LIBRARIES ${LAPACK_lapack_LIBRARY} ${LAPACK_blas_LIBRARY})
      set(LAPACK_FOUND TRUE)
    endif()
  endif()  

endif()

cmake_push_check_state()

set(CMAKE_REQUIRED_LIBRARIES ${LAPACK_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES} 
    ${CMAKE_THREAD_LIBS_INIT})

# Verify that we can link against BLAS
check_c_fortran_function_exists(sgemm BLAS_WORKS)

if(BLAS_WORKS)
  message(STATUS "A library with BLAS API found.")
else()
  message(FATAL_ERROR "Uable to link against BLAS function. Specify the BLAS library in LAPACK_LIBRARIES.")
endif()

# Verify that we can link against LAPACK
check_c_fortran_function_exists(cheev LAPACK_WORKS)

if(LAPACK_WORKS)
  message(STATUS "A library with LAPACK API found.")
else()
  message(FATAL_ERROR "Uable to link against LAPACK function. Specify the LAPACK library in LAPACK_LIBRARIES.")
endif()

set(LAPACK_FOUND TRUE)
message(STATUS "Found LAPACK: ${LAPACK_LIBRARIES}")

cmake_pop_check_state()
