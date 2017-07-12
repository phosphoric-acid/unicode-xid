
## common makefile for building rusty libraries

PREFIX ?= /usr/local
LIBDIR ?= $(PREFIX)/lib
RUSTC  ?= rustc

RUST_LIBDIR ?= $(LIBDIR)

TARGET_RLIB          = lib$(CRATE_NAME).rlib
TARGET_SO            = lib$(CRATE_NAME).so.$(SO_MAJOR).$(SO_MINOR).$(SO_PATCH)
TARGET_SO_LINK_MINOR = lib$(CRATE_NAME).so.$(SO_MAJOR).$(SO_MINOR)
TARGET_SO_LINK_MAJOR = lib$(CRATE_NAME).so.$(SO_MAJOR)
TARGET_SO_LINK       = lib$(CRATE_NAME).so

ALL_LIBS += $(TARGET_RLIB)

ifndef SO_DISABLE
ALL_LIBS += $(TARGET_SO) $(TARGET_SO_LINK) $(TARGET_SO_LINK_MINOR) $(TARGET_SO_LINK_MAJOR)
endif

all:	$(ALL_LIBS)

$(TARGET_RLIB):	$(SRCS)
	@$(RUSTC) $(MAIN_SRC) $(RUSTCFLAGS) --crate-type=rlib --crate-name $(CRATE_NAME) -o $@

$(TARGET_SO):	$(SRCS)
	@$(RUSTC) $(MAIN_SRC) $(RUSTCFLAGS) --crate-type=dylib --crate-name $(CRATE_NAME) -o $@

$(TARGET_SO_LINK_MINOR):	$(TARGET_SO)
	@ln -sf $(TARGET_SO) $@

$(TARGET_SO_LINK_MAJOR):	$(TARGET_SO_LINK_MINOR)
	@ln -sf $(TARGET_SO_LINK_MINOR) $@

$(TARGET_SO_LINK):	$(TARGET_SO_LINK_MAJOR)
	@ln -sf $(TARGET_SO_LINK_MAJOR) $@

install:	$(ALL_LIBS)
	@mkdir -p $(DESTDIR)/$(LIBDIR)
	@cp -d -p $(ALL_LIBS) $(DESTDIR)/$(RUST_LIBDIR)

clean:
	@rm -f $(TARGET_RLIB) \
	       $(TARGET_SO) \
	       $(TARGET_SO_LINK) \
	       $(TARGET_SO_LINK_MAJOR) \
	       $(TARGET_SO_LINK_MINOR)

uninstall:
	@rm -f $(DESTDIR)/$(RUST_LIBDIR)/$(TARGET_RLIB) \
	       $(DESTDIR)/$(RUST_LIBDIR)/$(TARGET_SO) \
	       $(DESTDIR)/$(RUST_LIBDIR)/$(TARGET_SO_LINK) \
	       $(DESTDIR)/$(RUST_LIBDIR)/$(TARGET_SO_LINK_MAJOR) \
	       $(DESTDIR)/$(RUST_LIBDIR)/$(TARGET_SO_LINK_MINOR)
