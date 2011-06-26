include $(top_srcdir)/build/Makefile.am.common

API_VERSION=			ADG_API_VERSION
BUILT_SOURCES=			$(abs_builddir)/api.lua \
				$(abs_builddir)/iface.c
CLEANFILES=		 	generator.log \
				parser.log \
				$(BUILT_SOURCES)
EXTRA_DIST=			adg.c \
				adg.ovr

cmoddir=			$(LUA_CMODULEDIR)/lgob
cmod_LTLIBRARIES= 		adg.la
nodist_adg_la_SOURCES=		iface.c
adg_la_CFLAGS=			-I $(LUA_INCLUDEDIR) \
				$(ADG_CFLAGS)
adg_la_LDFLAGS=			-module \
				$(ADG_LIBS)


$(abs_builddir)/iface.c: $(abs_srcdir)/adg.ovr $(abs_builddir)/api.lua
	$(GENERATE) -i $< -o $@ -v $(API_VERSION)

$(abs_builddir)/api.lua: /usr/share/gir-1.0/Adg-1.0.gir
	$(PARSE) -i $< -o $@
