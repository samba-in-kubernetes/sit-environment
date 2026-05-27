
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
  test           Create, build and test a site
  statedump      Dump the state of the site
endef

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

# Determine path of the site repository
DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Base directory of ansible
BASE := $(DIR)/ansible

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

SITE_DIR := $(VENV)/$(SITE)

# Default target
.DEFAULT_GOAL = test

.PHONY: help
help:
	$(info $(HELP_TEXT))
	@:

.PHONY: site site/$(SITE)
site site/$(SITE): $(SITE_DIR)

$(SITE_DIR):
	@$(PYTHON) -m venv --symlinks --prompt "SITE: $(SITE)" "$@"
	@source "$@/bin/activate" && pip install -r requirements.txt
	@sed 's#\$${SITE_DIR}#$@#g' <"$(BASE)/ansible.tpl" >"$@/ansible.cfg"
	@ln -s $$(realpath --relative-to "$@" "$(DIR)")/Makefile "$@"

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

ANSIBLE_EXTRA_VARS := -e 'site_dir=${SITE_DIR} site_name=${SITE} ${EXTRA_VARS}'

ansible = \
	cd "$(SITE_DIR)" && source "bin/activate" && \
	ansible-playbook --inventory localhost, $(addprefix --tags ,$(1)) \
		$(ANSIBLE_EXTRA_VARS) $(BASE)/site.yml

# Ansible targets

.PHONY: local
local: site
	@$(call ansible,initialize)

.PHONY: hosts.update.only
hosts.update.only: site
	@$(call ansible,update)

.PHONY: setup.prep.only
setup.prep.only: site
	@$(call ansible,prepare)

.PHONY: setup.prep
setup.prep: site
	@$(call ansible,initialize update prepare)

.PHONY: setup.cluster.only
setup.cluster.only: site
	@$(call ansible,cluster)

.PHONY: setup.cluster
setup.cluster: site
	@$(call ansible,initialize update prepare cluster)

.PHONY: setup.clients
setup.clients: site
	@$(call ansible,clients)

.PHONY: generate.report
generate.report: site
	@$(call ansible,report)

.PHONY: statedump nodes.statedump
statedump nodes.statedump: site
	@$(call ansible,statedump)

.PHONY: client.test
client.test: site
	@$(call ansible,test)

.PHONY: test setup.site
test setup.site: site
	@$(call ansible,initialize update prepare cluster clients report test)

.PHONY: clean
clean: site
	@$(call ansible,cleanup)
