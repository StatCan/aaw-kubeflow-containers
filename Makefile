# Misc Directories
TESTS_DIR := ./tests
MAKE_HELPERS := ./make_helpers/
PYTHON_VENV := .venv

# Executables
PYTHON := $(PYTHON_VENV)/bin/python
POST_BUILD_HOOK := post-build-hook.sh

# Default labels
DEFAULT_REPO := k8scc01covidacr.azurecr.io
GIT_SHA := $(shell git rev-parse HEAD)
# This works during local development, but if on a GitHub PR it will resolve to "HEAD"
# so don't rely on it when on the GH runners!
DEFAULT_TAG := $(shell ./make_helpers/get_branch_name.sh)
BRANCH_NAME := $(shell ./make_helpers/get_branch_name.sh)

# Other
DEFAULT_PORT := 8888
DEFAULT_NB_PREFIX := /notebook/username/notebookname

###################################
######    Docker helpers     ######
###################################

build/%: DARGS?=
build/%: REPO?=$(DEFAULT_REPO)
build/%: TAG?=$(DEFAULT_TAG)
build/%: ## build the latest image
	# End repo with exactly one trailing slash, unless it is empty
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" && \
	DOCKER_BUILDKIT=0 docker build $(DARGS) --rm --force-rm -t $$IMAGE_NAME -t zone-$(notdir $@) ./dockerfiles/$(notdir $@) && \
	echo -n "Built image $$IMAGE_NAME of size: " && \
	docker images $$IMAGE_NAME --format "{{.Size}}" && \
	echo "full_image_name=$$IMAGE_NAME" >> $(GITHUB_OUTPUT) && \
	echo "image_tag=$(TAG)" >> $(GITHUB_OUTPUT) && \
	echo "image_repo=$${REPO}" >> $(GITHUB_OUTPUT)

post-build/%: export REPO?=$(DEFAULT_REPO)
post-build/%: export TAG?=$(DEFAULT_TAG)
post-build/%: export SOURCE_FULL_IMAGE_NAME?=
post-build/%: export IMAGE_VERSION?=
post-build/%: export IS_LATEST?=
post-build/%:
	# TODO: could check for custom hook in the build's directory
	IMAGE_NAME="$(notdir $@)" \
	GIT_SHA=$(GIT_SHA) \
	BRANCH_NAME=$(BRANCH_NAME) \
	bash "$(MAKE_HELPERS)/$(POST_BUILD_HOOK)"

push/%: DARGS?=
push/%: REPO?=$(DEFAULT_REPO)
push/%:
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	echo "Pushing the following tags for $${REPO}$(notdir $@) (all tags)" &&\
	docker images $${REPO}$(notdir $@) --format="{{ .Tag }}" &&\
	docker push --all-tags $(DARGS) "$${REPO}"$(notdir $@)

###################################
######     Image Testing     ######
###################################
check-python-venv:
	@if $(PYTHON) --version> /dev/null 2>&1; then \
		echo "Found dev python venv via $(PYTHON)"; \
	else \
		echo -n 'No dev python venv found at $(PYTHON)\n' \
				'Please run `make install-python-dev-venv` to build a dev python venv'; \
		exit 1; \
	fi

check-port-available:
	@if curl http://localhost:$(DEFAULT_PORT) > /dev/null 2>&1; then \
		echo "Port $(DEFAULT_PORT) busy - clear port or change default before continuing"; \
		exit 1; \
	fi

check-test-prereqs: check-python-venv check-port-available

install-python-dev-venv:
	python3 -m venv $(PYTHON_VENV)
	$(PYTHON) -m pip install -Ur requirements-dev.txt

test/%: REPO?=$(DEFAULT_REPO)
test/%: TAG?=$(DEFAULT_TAG)
test/%: NB_PREFIX?=$(DEFAULT_NB_PREFIX)
test/%: check-test-prereqs # Run all generic and image-specific tests against an image
	# End repo with exactly one trailing slash, unless it is empty
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') ;\
	TESTS="$(TESTS_DIR)/general";\
	SPECIFIC_TEST_DIR="$(TESTS_DIR)/$(notdir $@)";\
	if [ ! -d "$${SPECIFIC_TEST_DIR}" ]; then\
		echo "No specific tests found for $${SPECIFIC_TEST_DIR}.  Running only general tests";\
	else\
		TESTS="$${TESTS} $${SPECIFIC_TEST_DIR}";\
		echo "Found specific tests folder";\
	fi;\
	echo "Running tests on folders '$${TESTS}'";\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" NB_PREFIX=$(DEFAULT_NB_PREFIX) $(PYTHON) -m pytest -m "not info" $${TESTS}
