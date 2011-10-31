include $(top_srcdir)/build/Makefile.am.common

API_VERSION=			CPML_API_VERSION

BUILT_SOURCES=			$(abs_builddir)/api.lua \
				$(abs_builddir)/iface.c
CLEANFILES=			generator.log \
				parser.log \
				$(BUILT_SOURCES)
EXTRA_DIST=			cpml.c \
				cpml.ovr

cmoddir=			$(LUA_CMODULEDIR)/lgob
cmod_LTLIBRARIES=		cpml.la
nodist_cpml_la_SOURCES=		iface.c
cpml_la_CFLAGS=			-I $(LUA_INCLUDEDIR) \
				$(CPML_CFLAGS)
cpml_la_LDFLAGS=		-module \
				$(CPML_LIBS)


$(abs_builddir)/iface.c: $(abs_srcdir)/cpml.ovr $(abs_builddir)/api.lua
	$(GENERATE) -i $< -o $@ -v $(API_VERSION)

$(abs_builddir)/api.lua:
	$(PARSE) -i Cpml-1.0.gir -o $@
