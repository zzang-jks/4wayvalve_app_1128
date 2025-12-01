# @file
# @brief Project makefile
# @internal
#
# @copyright (C) 2018-2020 Melexis N.V.
#
# Melexis N.V. is supplying this code for use with Melexis N.V. processor based microcontrollers only.
#
# THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.  MELEXIS N.V. SHALL NOT IN ANY CIRCUMSTANCES,
# BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
#
# @endinternal
#
# @ingroup application
#
# @details
# Makefile which will re-route targets to the correct folder and Makefile
#

# project folders
ROOT_DIR     = .
DOC_DIR      = $(ROOT_DIR)/code/doc
SRC_DIR      = $(ROOT_DIR)/code/src
LIB_DIR      = $(ROOT_DIR)/code/libraries
HIL_DIR      = $(ROOT_DIR)/verification/hil_tests
UTEST_DIR    = $(ROOT_DIR)/verification/unit_test

DOC_GOALS   := doxy_html doxy_pdf doxy_tex doxy_lua clean_doxy
LIB_DOC_GOALS := doxy
SRC_GOALS   := all clean drv clean_drv release release_hil lint size lin_signals_encoding.h
HIL_GOALS   := hil_tests
UNCR_GOALS  := uncrustify uncrustify-check
UTEST_GOALS := utest

ECHO = echo

.PHONY: help
help:
	@$(ECHO) "Usage: make [target] [OPTION=VALUE] ..."
	@$(ECHO)
	@$(ECHO) "General Targets:"
	@$(ECHO) "  help              Show this help information."
	@if [ -d "$(DOC_DIR)" ]; then \
	$(ECHO); \
	$(ECHO) "Documentation:"; \
	'$(MAKE)' --no-print-directory --directory=$(DOC_DIR) help-info HELP_LEADING="'  '"; \
	fi
	@$(ECHO)
	@$(ECHO) "Application:"
	@'$(MAKE)' --no-print-directory --directory=$(SRC_DIR) help-info HELP_LEADING="'  '"
	@if [ -d "$(HIL_DIR)" ]; then \
	$(ECHO); \
	$(ECHO) "HIL Test:"; \
	'$(MAKE)' --no-print-directory --directory=$(HIL_DIR) help-info HELP_LEADING="'  '"; \
	fi

.PHONY: $(DOC_GOALS)
$(DOC_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(DOC_DIR) $@

$(LIB_DOC_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(LIB_DIR) $@

.PHONY: $(SRC_GOALS)
$(SRC_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(SRC_DIR) $@

.PHONY: $(UNCR_GOALS)
$(UNCR_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(SRC_DIR) $@

.PHONY: $(HIL_GOALS)
$(HIL_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(HIL_DIR) $@

.PHONY: $(UTEST_GOALS)
$(UTEST_GOALS):
	@'$(MAKE)' --no-print-directory --directory=$(UTEST_DIR) $@
