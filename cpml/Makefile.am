include $(top_srcdir)/build/Makefile.am.common

API_VERSION=			CPML_API_VERSION
BUILT_SOURCES=			$(abs_builddir)/cpml.def \
				$(abs_builddir)/iface.c
CLEANFILES=		 	generator.log \
				parser.log \
				$(BUILT_SOURCES)
EXTRA_DIST=			cpml.ovr

cmoddir=			$(LUA_CMODULEDIR)/lgob
cmod_LTLIBRARIES= 		cpml.la
cpml_la_SOURCES=		cpml.c
nodist_cpml_la_SOURCES=		iface.c
cpml_la_CFLAGS=			-I $(LUA_INCLUDEDIR) \
				$(CPML_CFLAGS)
cpml_la_LDFLAGS=		-module \
				$(CPML_LIBS)


$(abs_builddir)/iface.c: $(abs_srcdir)/cpml.ovr $(abs_builddir)/cpml.def
	$(GENERATOR) -i $< -o $@ -l "$(abs_builddir)/generator.log" -v $(API_VERSION)

$(abs_builddir)/cpml.def: /usr/share/gir-1.0/Cpml-1.0.gir
	$(PARSER) -i $< -o $@ -l "$(abs_builddir)/parser.log"
