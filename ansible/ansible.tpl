[defaults]
any_errors_fatal = True
# This one is required by the GlusterFS backend, but it will be forcibly
# disabled by ansible in a future version
inject_facts_as_vars = True
callbacks_enabled = profile_tasks
interpreter_python = ${SITE_DIR}/bin/python3

[ssh_connection]
ssh_common_args = -F ${SITE_DIR}/ssh/config
