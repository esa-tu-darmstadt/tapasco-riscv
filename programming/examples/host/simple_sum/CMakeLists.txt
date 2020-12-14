cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
include($ENV{TAPASCO_HOME_RUNTIME}/cmake/Tapasco.cmake NO_POLICY_SCOPE)
project (simple_sum)

if(NOT TARGET tapasco)
    find_package(Tapasco REQUIRED)
endif()

find_package(Threads)

add_executable(simple_sum_host simple_sum_host.cpp)
set_tapasco_defaults(simple_sum_host)
target_link_libraries(simple_sum_host PRIVATE tapasco)


install(TARGETS simple_sum_host
        ARCHIVE  DESTINATION bin/
        LIBRARY  DESTINATION bin/
        RUNTIME  DESTINATION bin/)
