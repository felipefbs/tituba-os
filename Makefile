HOSTS := pc laptop pi
HOST ?= pc
RECIPE := recipes/$(HOST).yml

.PHONY: validate generate build iso switch clean help

help:
	@echo "Targets (HOST=$(HOST); available: $(HOSTS)):"
	@echo "  validate  - Validate every recipe ($(HOSTS))"
	@echo "  generate  - Render $(RECIPE) to a Containerfile"
	@echo "  build     - Build the image locally from $(RECIPE)"
	@echo "  iso       - Build a bootable offline ISO from $(RECIPE)"
	@echo "  switch    - Rebase the current OS onto a locally built image"
	@echo "  clean     - Remove local build artifacts (Containerfile, ISOs, bluebuild scripts)"
	@echo "Pick another machine with HOST=, e.g. make build HOST=laptop"

validate:
	@for h in $(HOSTS); do bluebuild validate recipes/$$h.yml || exit 1; done

generate:
	bluebuild generate $(RECIPE)

build:
	bluebuild build $(RECIPE)

iso:
	bluebuild generate-iso $(RECIPE)

switch:
	bluebuild switch $(RECIPE)

clean:
	rm -rf Containerfile *.iso *.iso-CHECKSUM .bluebuild-scripts_*
