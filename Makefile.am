ACLOCAL_AMFLAGS=		-I build


BUILT_SOURCES=			ChangeLog

EXTRA_DIST=			COPYING \
				INSTALL \
				NEWS \
				README \
				THANKS \
				$(BUILT_SOURCES)

dist_pkgdata_DATA=		demo.lua \
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
