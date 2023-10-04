INVENTORY := ./vagrant_ansible_inventory
VSSH := ssh -F ssh-config-host

ifdef EXTRA_VARS
	ANSIBLE_EXTRA_VARS := -e '${EXTRA_VARS}'
	SSH_EXTRA_VARS := EXTRA_VARS='${EXTRA_VARS}'
endif

local:
	@ansible-playbook --inventory localhost, ${ANSIBLE_EXTRA_VARS} local.yml

hosts.update.only:
	@ansible-playbook --inventory=$(INVENTORY) ${ANSIBLE_EXTRA_VARS} hosts.update.yml

setup.prep.only:
	@ansible-playbook --inventory=$(INVENTORY) ${ANSIBLE_EXTRA_VARS} setup.prep.yml

setup.prep: local hosts.update.only setup.prep.only

setup.prep.copy:
	@ansible-playbook --inventory=$(INVENTORY) ${ANSIBLE_EXTRA_VARS} --start-at-task "copy ansible playbooks to setup machine" setup.prep.yml

setup.test.only:
	@ansible-playbook --inventory=$(INVENTORY) ${ANSIBLE_EXTRA_VARS} setup.test.yml

setup.cluster.only:
	@$(VSSH) admin "${SSH_EXTRA_VARS} make -C ansible setup.cluster"

setup.cluster: setup.prep setup.test.only setup.cluster.only

setup.clients:
	@$(VSSH) admin "${SSH_EXTRA_VARS} make -C ansible setup.clients"

generate.report:
	@$(VSSH) admin "${SSH_EXTRA_VARS} make -C ansible generate.report"

nodes.statedump:
	@ansible-playbook --inventory $(INVENTORY) ${ANSIBLE_EXTRA_VARS} nodes.statedump.yml

client.test:
	@$(VSSH) admin "${SSH_EXTRA_VARS} make -C ansible client.test"

setup.site: setup.cluster setup.clients generate.report client.test

client1.test:
	@$(VSSH) clients "sudo make -C /root/sit-test-cases test"

clean:
	@ansible-playbook --inventory localhost, ${ANSIBLE_EXTRA_VARS} cleanup.yml

.PHONY: local hosts.update.only setup.prep.only setup.prep setup.test.only setup.cluster.only setup.cluster setup.clients client.test setup.site client1.test clean
