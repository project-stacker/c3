include config.mk

SUBDIRS := images

.PHONY: all
all: subdirs

.PHONY: subdirs
subdirs:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

.PHONY: clean
clean: 
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
