RECIPE := recipes/recipe.yml

.PHONY: validate generate build iso switch clean help

help:
	@echo "Targets:"
	@echo "  validate  - Validate $(RECIPE)"
	@echo "  generate  - Render $(RECIPE) to a Containerfile"
	@echo "  build     - Build the image locally from $(RECIPE)"
	@echo "  iso       - Build a bootable offline ISO from $(RECIPE)"
	@echo "  switch    - Rebase the current OS onto a locally built image"
	@echo "  clean     - Remove local build artifacts (Containerfile, ISOs, bluebuild scripts)"

validate:
	bluebuild validate $(RECIPE)

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
