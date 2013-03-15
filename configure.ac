m4_define([adg_lua_version],[0.1.0])

m4_define([lua_prereq],5.1.0)
m4_define([adg_prereq],0.7.1)


# Initialization

dnl Depends on the same autoconf version of the ADG project
AC_PREREQ([2.62])
AC_INIT([adg-lua],adg_lua_version,[http://dev.entidi.com/p/adg-lua/],[adg-lua],[http://adg.entidi.com/])
AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_AUX_DIR([build])
AC_CONFIG_MACRO_DIR([build])
AM_INIT_AUTOMAKE([1.10 gnits no-dist-gzip dist-bzip2 -Wall -Wno-portability])

dnl m4 backward compatibility stuff
m4_ifdef([AM_SILENT_RULES],
         [AM_SILENT_RULES([yes])],
         [AC_SUBST([AM_V_GEN],[])])
m4_ifdef([AM_SUBST_NOTMAKE],[],
         [AC_DEFUN([AM_SUBST_NOTMAKE],[_AM_SUBST_NOTMAKE($@)])])
m4_ifdef([AM_COND_IF],[],
         [AC_DEFUN([AM_COND_IF],
                   [AS_IF([test -z "$$1_TRUE"],[$2],[$3])])])


# Check for programs

AX_PROG_LUA(adg_prereq)
PKG_PROG_PKG_CONFIG


# Check for required packages

dnl Get adgdatadir: if not set, use a sensible default and check for
dnl adg-demo.ui existence inside the guessed path.
AC_ARG_WITH(adgdatadir,
            [AS_HELP_STRING([--with-adg-data-dir=DIR],
                            [path to the ADG package data @<:@default=DATAROOTDIR/adg@:>@])])
AS_IF([test "x$with_adgdatadir" = "x"],
      [with_adgdatadir="$($PKG_CONFIG --variable=datadir adg-1)/adg"
       AS_IF([test -f "$with_adgdatadir/adg-demo.ui"],[:],
             [AC_MSG_ERROR([adg-demo.ui missing in adgdatadir ($with_adgdatadir)])])])
AC_SUBST([ADGDATADIR],${with_adgdatadir})


# Generation

AC_CONFIG_FILES([adg-demo.lua
                 Makefile])
AC_OUTPUT


# Report

AC_MSG_NOTICE([generating report

AC_PACKAGE_NAME adg_lua_version will be built with the following options:
----------------------------------------------------------
          Lua interpreter: ${LUA} (version ${LUA_VERSION})
              LGI library: not checked
 Path to ADG package data: ${with_adgdatadir}
])
