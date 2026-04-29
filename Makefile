
define HELP_TEXT
Usage: $(MAKE) [options] [target]

Options (can be passed as command options or environment variables):
  SITE=<name>    Specify the site to use (default: 'site')

                 The site name can also be derived from:

                 - Active Python virtual environment name
                 - Site subdirectory when make is executed from within it
                 - Target pattern site/<name>

                 If multiple sources provide conflicting site names, execution
                 stops with an error.

  PYTHON=<cmd>   Specify the Python interpreter to use (default: 'python3')

  YAMLLINT=<cmd> Specify the yaml lint command to use (default: 'yamllint')

Targets (only one target allowed per invocation):
  help           Display this help message
  clean          Cleanup resources used by the current site
  site           Create Python virtual environment for default site
  site/<site>    Create Python virtual environment with specified name
  destroy        Destroy current Python virtual environment
endef
export HELP_TEXT

# Enforce a single goal (at most) in the command line
ifneq ($(word 2,$(MAKECMDGOALS)),)
$(error Only one goal is allowed)
endif

# Disable builtin rules and prevent printing of directory changes
MAKEFLAGS += --no-builtin-rules --no-print-directory

# Check that the provided site in $(1) is a valid python virtual environment
# and that it's compatible with the current site, if any. It also makes sure
# that the goal is not "destroy", since we cannot destroy a site that is in
# use.
set_site = \
	$(strip \
		$(if $(filter $(dir $(1)),$(VENV)/), \
			$(if $(filter-out $(notdir $(1)),$(SITE)), \
				$(error Trying to work on '$(notdir $(1))' from '$(SITE)'), \
				$(if $(filter destroy,$(MAKECMDGOALS)), \
					$(error Trying to remove '$(notdir $(1))' while in use), \
					$(notdir $(1)) \
				) \
			), \
			$(error Invalid python venv '$(1)') \
		) \
	)

# Determine parent directory of the current Makefile
MFD := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export MFD

# Determine path of the site repository
DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Base directory of ansible
BASE := $(DIR)/ansible
export BASE

# Base directory for python virtual environments
VENV := $(DIR)/sites

# Default python interpreter
PYTHON ?= python3

# Default yaml lint program
YAMLLINT ?= yamllint

# Check if the Makefile is inside a python virtual environment. If so, update
# the SITE.
ifneq ($(wildcard $(MFD)/bin/activate),)
SITE := $(call set_site,$(MFD))
endif

# Check if we are running in an active python virtual environment. If so,
# update the SITE.
ifdef VIRTUAL_ENV
SITE := $(call set_site,$(VIRTUAL_ENV))
endif

# If explicitly creating a virtual environment from the command line, update
# the SITE.
ifneq ($(filter site/%,$(MAKECMDGOALS)),)
SITE := $(call set_site,$(subst site/,$(VENV)/,$(MAKECMDGOALS)))
endif

# Set the default SITE if none has been detected or provided
SITE ?= default
export SITE

SITE_DIR := $(VENV)/$(SITE)
export SITE_DIR

GLOBAL_GOALS := all help site site/$(SITE) $(SITE_DIR) destroy yamllint

.PHONY: all clean
GOALS := all $(filter-out $(GLOBAL_GOALS),$(MAKECMDGOALS))

$(GOALS): site
ifndef VIRTUAL_ENV
	@source "$(SITE_DIR)/bin/activate" && \
		$(MAKE) -C "$(SITE_DIR)" $(MAKECMDGOALS)
else
	@cd "$(SITE_DIR)" && $(MAKE) -f "$(BASE)/Makefile.site" $(MAKECMDGOALS)
endif

.PHONY: help
help:
	@cat <<< "$${HELP_TEXT}"
	@$(MAKE) -f "$(BASE)/Makefile.site" help

$(SITE_DIR):
	@$(PYTHON) -m venv --symlinks --prompt "SITE: $(SITE)" "$@"
	@source "$@/bin/activate" && pip install -r requirements.txt
	@cp "$(BASE)/ansible.cfg" "$@/"
	@ln -s $$(realpath --relative-to "$@" "$(MFD)")/Makefile "$@"

.PHONY: site site/$(SITE)
site site/$(SITE): $(SITE_DIR)

.PHONY: destroy
destroy:
ifneq ($(wildcard $(SITE_DIR)),)
ifeq ($(wildcard $(SITE_DIR)/config.yml),)
	@rm -rf "${SITE_DIR}"
else
	$(error Site '$(SITE)' is still configured)
endif
endif

.PHONY: yamllint
yamllint:
	@$(YAMLLINT) -c "$(DIR)/.yamllint" "$(DIR)"
