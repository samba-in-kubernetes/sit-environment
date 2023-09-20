.PHONY: test clean yamllint

test:
	@$(MAKE) -C vagrant setup.site

statedump:
	@$(MAKE) -C vagrant nodes.statedump

clean:
	@$(MAKE) -C vagrant clean

yamllint:
	@yamllint -c .yamllint .
