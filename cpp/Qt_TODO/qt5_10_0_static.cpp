// Add to CMakeLists.txt
// add_definitions(-DRZ_QT_STATIC)
// link_directories(
//     $ENV{QTDIR}/lib
//     $ENV{QTDIR}/plugins/platforms)

#ifdef RZ_QT_STATIC
#include <QtPlugin>
#endif

#include "../mocs_compilation.cpp" // TODO: CMAKE

#ifdef RZ_QT_STATIC
Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
#pragma comment(lib, "imm32.lib")
#pragma comment(lib, "d3d9.lib")
#pragma comment(lib, "dxguid.lib")
#pragma comment(lib, "Ws2_32.lib")
#pragma comment(lib, "Winmm.lib")
#pragma comment(lib, "UxTheme.lib")
#pragma comment(lib, "Dwmapi.lib")
#pragma comment(lib, "Mincore.lib")
#pragma comment(lib, "Netapi32.lib")
#pragma comment(lib, "Userenv.lib")
#ifdef _DEBUG
    // lib
#   pragma comment(lib, "Qt5AccessibilitySupportd.lib")
#   pragma comment(lib, "Qt5EglSupportd.lib")
#   pragma comment(lib, "Qt5EventDispatcherSupportd.lib")
#   pragma comment(lib, "Qt5FontDatabaseSupportd.lib")
#   pragma comment(lib, "Qt5OpenGLd.lib")
#   pragma comment(lib, "Qt5OpenGLExtensionsd.lib")
#   pragma comment(lib, "Qt5PlatformCompositorSupportd.lib")
#   pragma comment(lib, "Qt5ThemeSupportd.lib")
#   pragma comment(lib, "QtANGLEd.lib")
#   pragma comment(lib, "preprocessord.lib")
#   pragma comment(lib, "qtfreetyped.lib")
#   pragma comment(lib, "qtharfbuzzd.lib")
#   pragma comment(lib, "qtlibpngd.lib")
#   pragma comment(lib, "qtpcre2d.lib")
#   pragma comment(lib, "translatord.lib")
    // plugins/platforms
#   pragma comment(lib, "qwindowsd.lib")
#else // !_DEBUG (RELEASE)
    // lib
#   pragma comment(lib, "Qt5AccessibilitySupport.lib")
#   pragma comment(lib, "Qt5EglSupport.lib")
#   pragma comment(lib, "Qt5EventDispatcherSupport.lib")
#   pragma comment(lib, "Qt5FontDatabaseSupport.lib")
#   pragma comment(lib, "Qt5OpenGL.lib")
#   pragma comment(lib, "Qt5OpenGLExtensions.lib")
#   pragma comment(lib, "Qt5PlatformCompositorSupport.lib")
#   pragma comment(lib, "Qt5ThemeSupport.lib")
#   pragma comment(lib, "QtANGLE.lib")
#   pragma comment(lib, "preprocessor.lib")
#   pragma comment(lib, "qtfreetype.lib")
#   pragma comment(lib, "qtharfbuzz.lib")
#   pragma comment(lib, "qtlibpng.lib")
#   pragma comment(lib, "qtpcre2.lib")
#   pragma comment(lib, "translator.lib")
    // plugins/platforms
#   pragma comment(lib, "qwindows.lib")
#endif // _DEBUG
#endif // RZ_QT_STATIC