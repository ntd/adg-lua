m4_define([adg_lua_version],[0.0.1])

m4_define([cpml_prereq],[0.6.3])
m4_define([cpml_api_version],1.0)
m4_define([adg_prereq],cpml_prereq)
m4_define([adg_api_version],1.0)
m4_define([lua_prereq],5.1.0)


# Initialization

dnl autoconf and automake versions here should be the same
dnl as the ones required by the adg package (just for laziness)
AC_PREREQ([2.62])
AC_INIT([adg-lua],adg_lua_version,[http://dev.entidi.com/p/adg/],[adg-lua],[http://adg.entidi.com/])
AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_AUX_DIR([build])
AC_CONFIG_MACRO_DIR([build])
AM_INIT_AUTOMAKE([1.11 gnits no-dist-gzip dist-bzip2 -Wall -Wno-portability])
AM_SILENT_RULES([yes])


# Check for programs

AC_PROG_CC
AC_PROG_SED
PKG_PROG_PKG_CONFIG
AC_PATH_PROG([PARSER],[lgob-gir-parser],[/usr/bin/lgob-gir-parser])
AC_PATH_PROG([GENERATOR],[lgob-generator],[/usr/bin/lgob-generator])

# Libtool initialization

AC_MSG_CHECKING([which libtool initialization strategy to adopt])
AC_MSG_RESULT([m4_ifset([LT_INIT],[LT-INIT],[AC-PROG-LIBTOOL])])
m4_ifset([LT_INIT],
         [LT_INIT([disable-static win32-dll])],
         [AC_DISABLE_STATIC
          AC_LIBTOOL_WIN32_DLL
          AC_PROG_LIBTOOL])


# Check for required packages

PKG_CHECK_MODULES([CPML],[cpml-1 >= ]cpml_prereq)
PKG_CHECK_MODULES([ADG],[adg-1 >= ]adg_prereq)
PKG_CHECK_MODULES([LUA],[lua >= ]lua_prereq)


# Check for Lua/lgob dirs
 
AC_ARG_WITH(lua-includedir,
	    [AS_HELP_STRING([--with-lua-includedir],
			    [prefix where Lua headers are installed @<:@INSTALL_INC@:>@])],
            lua_includedir="$withval", lua_includedir="$(${PKG_CONFIG} --variable=INSTALL_INC lua)")
AC_SUBST([LUA_INCLUDEDIR],"$lua_includedir")
AC_ARG_WITH(lua-cmoduledir,
	    [AS_HELP_STRING([--with-lua-cmoduledir],
			    [prefix where Lua C modules are installed @<:@INSTALL_CMOD@:>@])],
            lua_cmoduledir="$withval", lua_cmoduledir="$(${PKG_CONFIG} --variable=INSTALL_CMOD lua)")
AC_SUBST([LUA_CMODULEDIR],"$lua_cmoduledir")


# Substitutions

AC_SUBST([CPML_API_VERSION],cpml_api_version)
AC_SUBST([ADG_API_VERSION],adg_api_version)


# Generation

AC_CONFIG_FILES([Makefile
		 cpml/Makefile
                 adg/Makefile
		 examples/Makefile])
AC_OUTPUT


# Report

AC_MSG_NOTICE([generating report

AC_PACKAGE_NAME adg_lua_version will be built with the following options:
----------------------------------------------------------
              CPML bindings version: cpml_api_version
               ADG bindings version: adg_api_version
                Path to Lua headers: ${lua_includedir}
              Path to Lua C modules: ${lua_cmoduledir}
])
