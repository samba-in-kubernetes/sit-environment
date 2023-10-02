.PHONY: test statedump clean yamllint

test:
	@$(MAKE) -C playbooks setup.site

statedump:
	@$(MAKE) -C playbooks nodes.statedump

clean:
	@$(MAKE) -C playbooks clean

yamllint:
	@yamllint -c .yamllint .
