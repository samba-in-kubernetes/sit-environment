.PHONY: test clean yamllint

test:
	@$(MAKE) -C vagrant setup.site

clean:
	@$(MAKE) -C vagrant clean

yamllint:
	@yamllint -c .yamllint .
