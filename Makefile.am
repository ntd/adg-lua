ACLOCAL_AMFLAGS=		-I build


BUILT_SOURCES=			ChangeLog

EXTRA_DIST=			COPYING \
				INSTALL \
				NEWS \
				README \
				THANKS \
				$(BUILT_SOURCES)

pkgdata_DATA=			adg-demo.lua
dist_pkgdata_DATA=		adg-web.lua \
				piston.lua


# Creating ChangeLog files from git log:
# idea stolen from cairo/build/Makefile.am.changelog
ChangeLog:
	$(AM_V_GEN)if test -d "$(srcdir)/.git"; then \
	  ( cd "$(srcdir)" && git log --stat > $@ ) ; \
	else \
	  echo ' *WARN  A git checkout is required to generate $@' ; \
	  touch $@ ; \
	fi


# rockspec handling, based on instruction by Reuben Thomas found at
# http://luarocks.org/en/Creating_LuaRocks_with_GNU_autotools

ROCKSPEC = $(PACKAGE_TARNAME)-$(VERSION)-1.rockspec

rock: $(ROCKSPEC)

$(ROCKSPEC): rockspec dist dist
	$(AM_V_GEN)set -- `$(MD5SUM) $(distdir).tar.bz2` ; \
	sed -e "s/@MD5@/$$1/" < $< > $@

EXTRA_DIST+=			rockspec.in
DISTCLEANFILES=			rockspec

.PHONY: rock
