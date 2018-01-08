add_library(libx264 STATIC IMPORTED)
set_property(TARGET libx264 PROPERTY IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/lib/libx264.lib)
include_directories(${CMAKE_CURRENT_LIST_DIR}/include)

# if (MSVC)
#     include(3rd/x264_XXX/libx264.cmake)
#     target_link_libraries(APP_NAME libx264)
# endif()