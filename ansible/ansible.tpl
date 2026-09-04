[defaults]
log_path = ${SITE_DIR}/site.log
any_errors_fatal = True
# This one is required by the GlusterFS backend, but it will be forcibly
# disabled by ansible in a future version
inject_facts_as_vars = True
callbacks_enabled = profile_tasks
interpreter_python = ${SITE_DIR}/bin/python3
home = ${SITE_DIR}/ansible
library = ${SITE_DIR}/ansible/plugins/modules
collections_path = ${SITE_DIR}/ansible/collections
roles_path = ${SITE_DIR}/ansible/roles
action_plugins = ${SITE_DIR}/ansible/plugins/action
become_plugins = ${SITE_DIR}/ansible/plugins/become
cache_plugins = ${SITE_DIR}/ansible/plugins/cache
callback_plugins = ${SITE_DIR}/ansible/plugins/callback
cliconf_plugins = ${SITE_DIR}/ansible/plugins/cliconf
connection_plugins = ${SITE_DIR}/ansible/plugins/connection
doc_fragment_plugins = ${SITE_DIR}/ansible/plugins/doc_fragments
filter_plugins = ${SITE_DIR}/ansible/plugins/filter
httpapi_plugins = ${SITE_DIR}/ansible/plugins/httpapi
inventory_plugins = ${SITE_DIR}/ansible/plugins/inventory
lookup_plugins = ${SITE_DIR}/ansible/plugins/lookup
module_utils = ${SITE_DIR}/ansible/plugins/module_utils
netconf_plugins = ${SITE_DIR}/ansible/plugins/netconf
strategy_plugins = ${SITE_DIR}/ansible/plugins/strategy
terminal_plugins = ${SITE_DIR}/ansible/plugins/terminal
test_plugins = ${SITE_DIR}/ansible/plugins/test
vars_plugins = ${SITE_DIR}/ansible/plugins/vars

[ssh_connection]
ssh_common_args = -F ${SITE_DIR}/ssh/config
