include ../config.mk
PKG_PACKAGES=adg-1 $(PKG_LUA)
NAME=adg.so
VERSION=1.0
include ../flags.mk

$(NAME): adg.o
	$(CC) adg.o -o $(NAME) $(LDFLAGS)

adg.o: src/iface.c src/adg.c
	$(CC) $(CFLAGS) src/iface.c -o adg.o

src/iface.c: src/adg.def src/adg.ovr
	$(GEN) -i "$(PWD)/src/adg.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/generator.log" -v $(VERSION)

src/adg.def:
	$(PARSER) -i /usr/share/gir-1.0/Adg-1.0.gir -o "$(PWD)/src/adg.def" -l "$(PWD)/parser.log"

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) adg.o $(NAME) src/iface.c src/adg.def generator.log parser.log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
