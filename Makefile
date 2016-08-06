PACKAGE = rebol-lib
VERSION = 0.0.1
PLATFORM = kbox
DESCRIPTION = "some Rebol libraries"
DEB = ${PACKAGE}_${VERSION}_${PLATFORM}.deb
FILES = \
usr \
usr/bin \
usr/bin/rebol3.sh \
usr/bin/rebol.r \
usr/lib \
usr/lib/r3 \
usr/lib/r3/rewrite.r \
usr/lib/r3/lest.reb \
usr/lib/r3/profile.reb \
usr/lib/r3/altjson.reb \
usr/lib/r3/recode.reb \
usr/lib/r3/sl4a.reb \
usr/lib/r3/html.reb \
usr/lib/r3/sort.reb \
usr/lib/r3/text.reb \
usr/lib/r3/shttpd.reb \
usr/share/scripts/shttpd.reb

${DEB}: data.tar.gz control.tar.gz debian-binary
	ar r $@ debian-binary data.tar.gz control.tar.gz

data.tar.gz: ${FILES}
	tar cf data.tar ${FILES}
	rm -f data.tar.gz
	gzip data.tar

control.tar.gz: control
	tar cf control.tar ./control
	rm -f control.tar.gz
	gzip control.tar

debian-binary:
	echo 2.0 > $@

control:
	echo -e \
	"Package: ${PACKAGE}\n\
	Version: ${VERSION}\n\
	Description:" > $@

.PHONY: sync
sync:
	@for o in ${FILES}; do \
	  i=/$$o; \
	  [ -f $$i ] || continue; \
	  if [ $$i -nt $$o ]; then \
	    echo update '->' $$o '?'; \
	    echo '[(yes) r(everse), n(o)]'; \
	    read x; \
	    case $$x in \
	    r*) cp -a $$o $$i ;; \
	    n*) ;; \
	    *) cp -a $$i $$o ;; \
	    esac; \
	  else \
	    if [ $$o -nt $$i ]; then \
	      echo install '<-' $$o '?'; \
	      echo '[(yes), r(everse), n(o)]';\
	      read x; \
	      case $$x in \
	      r*) cp -a $$i $$o ;; \
	      n*) ;; \
	      *) cp -a $$o $$i ;; \
	      esac; \
	    fi; \
	  fi; \
	done

.PHONY: comp
comp:
	@for o in ${FILES}; do \
	  i=/$$o; \
	  [ -f $$i ] || continue; \
	  if [ $$i -nt $$o ]; then \
	    echo update '->' $$o; \
	  else \
	    if [ $$o -nt $$i ]; then \
	      echo install '<-' $$o; \
	    fi; \
	  fi; \
	done

.PHONY: clean
clean:
	rm ${DEB} control.tar.gz data.tar.gz