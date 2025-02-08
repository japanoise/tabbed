.POSIX:

NAME = tabbed
VERSION = 0.8

# paths
# Global path locations.
PORTSDIR ?= /usr/ports
X11BASE ?= /usr/X11R6
VARBASE ?= /var
DISTDIR ?= ${PORTSDIR}/distfiles
BULK_COOKIES_DIR ?= ${PORTSDIR}/bulk/${MACHINE_ARCH}
UPDATE_COOKIES_DIR ?= ${PORTSDIR}/update/${MACHINE_ARCH}
PREFIX ?= /usr/local
MANPREFIX = ${PREFIX}/man
DOCPREFIX = ${PREFIX}/share/doc/${NAME}

# use system flags.
TABBED_CFLAGS = -I${X11BASE}/include -I${X11BASE}/include/freetype2 ${CFLAGS}
TABBED_LDFLAGS = -L${X11BASE}/lib -lX11 -lfontconfig -lXft ${LDFLAGS}
TABBED_CPPFLAGS = -DVERSION=\"${VERSION}\" -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=700L

# OpenBSD (uncomment)
#TABBED_CFLAGS = -I/usr/X11R6/include -I/usr/X11R6/include/freetype2 ${CFLAGS}

SRC = tabbed.c xembed.c
OBJ = ${SRC:.c=.o}
BIN = ${OBJ:.o=}
MAN1 = ${BIN:=.1}
HDR = arg.h config.def.h
DOC = LICENSE README

all: ${BIN}

.c.o:
	${CC} -o $@ -c $< ${TABBED_CFLAGS} ${TABBED_CPPFLAGS}

${OBJ}: config.h

config.h:
	cp config.def.h $@

.o:
	${CC} -o $@ $< ${TABBED_LDFLAGS}

clean:
	rm -f ${BIN} ${OBJ} "${NAME}-${VERSION}.tar.gz"

dist: clean
	mkdir -p "${NAME}-${VERSION}"
	cp -fR Makefile ${MAN1} ${DOC} ${HDR} ${SRC} "${NAME}-${VERSION}"
	tar -cf - "${NAME}-${VERSION}" | gzip -c > "${NAME}-${VERSION}.tar.gz"
	rm -rf ${NAME}-${VERSION}

install: all
	${BSD_INSTALL_PROGRAM_DIR} ${DESTDIR}${PREFIX}/bin
	${BSD_INSTALL_PROGRAM} ${BIN} ${DESTDIR}${PREFIX}/bin
	${BSD_INSTALL_MAN_DIR} ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < tabbed.1 > tabbed.1.tmp
	mv tabbed.1.tmp tabbed.1
	${BSD_INSTALL_MAN} tabbed.1 ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < xembed.1 > xembed.1.tmp
	mv xembed.1.tmp xembed.1
	${BSD_INSTALL_MAN} xembed.1 ${DESTDIR}${MANPREFIX}/man1

uninstall:
	# removing executable files.
	for f in ${BIN}; do rm -f "${DESTDIR}${PREFIX}/bin/$$f"; done
	# removing doc files.
	rm -f "${DESTDIR}${DOCPREFIX}/README"
	# removing manual pages.
	for m in ${MAN1}; do rm -f "${DESTDIR}${MANPREFIX}/man1/$$m"; done
	-rmdir "${DESTDIR}${DOCPREFIX}"

.PHONY: all clean dist install uninstall
