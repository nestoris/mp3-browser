# Makefile для mp3-browser
PREFIX  ?= /usr
DESTDIR ?=
OPT_DIR  = /opt/mp3-browser

install:
	install -d "$(DESTDIR)$(OPT_DIR)"
	install -m755 mp3-browser.js  "$(DESTDIR)$(OPT_DIR)/"
	install -m755 mp3-scanner.js  "$(DESTDIR)$(OPT_DIR)/"

	install -d "$(DESTDIR)$(PREFIX)/bin"
	ln -sf "$(OPT_DIR)/mp3-browser.js" "$(DESTDIR)$(PREFIX)/bin/mp3-browser"
	ln -sf "$(OPT_DIR)/mp3-scanner.js" "$(DESTDIR)$(PREFIX)/bin/mp3-scanner"

	install -Dm644 mp3-browser.desktop \
		"$(DESTDIR)$(PREFIX)/share/applications/mp3-browser.desktop"

.PHONY: install