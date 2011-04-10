include ../config.mk
PKG_PACKAGES=cpml-1 gobject-2.0 $(PKG_LUA)
NAME=cpml.so
VERSION=1.0
include ../flags.mk

$(NAME): cpml.o
	$(CC) cpml.o -o $(NAME) $(LDFLAGS)

cpml.o: src/iface.c src/cpml.c
	$(CC) $(CFLAGS) src/iface.c -o cpml.o

src/iface.c: src/cpml.def src/cpml.ovr
	$(GEN) -i "$(PWD)/src/cpml.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/generator.log" -v $(VERSION)

src/cpml.def:
	$(PARSER) -i /usr/share/gir-1.0/Cpml-1.0.gir -o "$(PWD)/src/cpml.def" -l "$(PWD)/parser.log"

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) cpml.o $(NAME) src/iface.c src/cpml.def generator.log parser.log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
