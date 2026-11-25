PORTNAME=		darkmod-data
DISTVERSION=		2.14
CATEGORIES=		games

MAINTAINER=		your@email.here
COMMENT=		Game data files for The Dark Mod (fetched by official installer)
WWW=			https://www.thedarkmod.com/

MASTER_SITES=		https://update.thedarkmod.com/zipsync/ \
			https://web.archive.org/web/20260729210301if_/https://update.thedarkmod.com/zipsync/
DISTNAME=		tdm_installer.linux64
EXTRACT_SUFX=		.zip

LICENSE=		CC-BY-NC-SA-3.0

ONLY_FOR_ARCHS=		amd64
ONLY_FOR_ARCHS_REASON=	Official installer is a Linux x86_64 binary

USES=			linux:rl9 zip
USE_LINUX=		xorglibs

BUILD_DEPENDS=		${LOCALBASE}/bin/Xvfb:x11-servers/xlibre-vfb

NO_ARCH=		yes
#NO_BUILD=		yes
#NO_WRKSUBDIR=		yes			# binary extracts directly into WRKDIR

DATADIR=		${PREFIX}/share/darkmod
INSTALL_DIR=		${WRKDIR}/darkmod-install

post-extract:
	${CHMOD} +x ${WRKDIR}/tdm_installer.linux64

do-build:
	Xvfb :99 -screen 0 1024x768x24 & echo $$! > ${WRKDIR}/.xvfb.pid
	sleep 2
	cd ${WRKDIR} && ${SETENV} DISPLAY=:99 HOME=${WRKDIR} \
		./tdm_installer.linux64 --unattended & echo $$! > ${WRKDIR}/.installer.pid
	@echo "===>  tdm_installer running (pid $$(cat ${WRKDIR}/.installer.pid))"
	@while kill -0 $$(cat ${WRKDIR}/.installer.pid) 2>/dev/null; do \
		printf '.'; \
		sleep 2; \
	done; \
	echo; \
	echo "===>  tdm_installer finished"
	-kill `cat ${WRKDIR}/.xvfb.pid` 2>/dev/null || true

do-install:
	@if [ ! -f ${WRKDIR}/tdm_base01.pk4 ]; then \
		${ECHO_MSG} "ERROR: tdm_base01.pk4 missing – run the installer manually once first" ; \
		exit 1 ; \
	fi

	${MKDIR} ${STAGEDIR}${DATADIR}

	cd ${WRKDIR} && \
		${COPYTREE_SHARE} "*.pk4" ${STAGEDIR}${DATADIR} && \
		${COPYTREE_SHARE} "fms" ${STAGEDIR}${DATADIR}

	for f in Darkmod.cfg DarkmodKeybinds.cfg DarkmodPadbinds.cfg \
		alsoft.ini alsoft-hrtf-default-44100.mhr alsoft-hrtf-default-48000.mhr \
		AUTHORS.txt LICENSE.txt description.txt \
		tdm_shared_stuff.zip ca-bundle.crt; do \
		if [ -f ${WRKDIR}/$$f ]; then \
			${INSTALL_DATA} ${WRKDIR}/$$f ${STAGEDIR}${DATADIR}/ ; \
		fi ; \
	done

	${MKDIR} ${STAGEDIR}${DATADIR}/fms
	${CHMOD} 1777 ${STAGEDIR}${DATADIR}/fms

.include <bsd.port.mk>
