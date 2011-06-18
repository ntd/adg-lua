include $(top_srcdir)/build/Makefile.am.common

API_VERSION=			ADG_API_VERSION
BUILT_SOURCES=			$(abs_builddir)/adg.def \
				$(abs_builddir)/iface.c
CLEANFILES=		 	generator.log \
				parser.log \
				$(BUILT_SOURCES)
EXTRA_DIST=			adg.ovr

cmoddir=			$(LUA_CMODULEDIR)/lgob
cmod_LTLIBRARIES= 		adg.la
adg_la_SOURCES=			adg.c
nodist_adg_la_SOURCES=		iface.c
adg_la_CFLAGS=			-I $(LUA_INCLUDEDIR) \
				$(ADG_CFLAGS)
adg_la_LDFLAGS=			-module \
				$(ADG_LIBS)


$(abs_builddir)/iface.c: $(abs_srcdir)/adg.ovr $(abs_builddir)/adg.def
	$(GENERATOR) -i $< -o $@ -l "$(abs_builddir)/generator.log" -v $(API_VERSION)

$(abs_builddir)/adg.def: /usr/share/gir-1.0/Adg-1.0.gir
	$(PARSER) -i $< -o $@ -l "$(abs_builddir)/parser.log"
