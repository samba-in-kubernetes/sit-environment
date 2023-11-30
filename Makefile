.PHONY: test statedump clean yamllint

test:
	@./site create test
	@./site build test

statedump:
	@./site statedump test

clean:
	@./site destroy test

yamllint:
	@./site yamllint
