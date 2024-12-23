# Dockerfile Builder
# ==================
#
# All the content is in `docker-bits`; this Makefile
# just builds target dockerfiles by combining the dockerbits.
#
# Management of build, pull/push, and testing is modified from
# https://github.com/jupyter/docker-stacks
#
# Tests/some elements of makefile strongly inspired by
# https://github.com/jupyter/docker-stacks/blob/master/Makefile

# The docker-stacks tag
DOCKER-STACKS-UPSTREAM-TAG := ed2908bbb62e

tensorflow-CUDA := 11.8.0
pytorch-CUDA    := 11.8.0

# https://stackoverflow.com/questions/5917413/concatenate-multiple-files-but-include-filename-as-section-headers
CAT := awk '(FNR==1){print "\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n\#\#\#  " FILENAME "\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n"}1'

# Misc Directories
SRC := docker-bits
RESOURCES := resources
OUT := output
TMP := .tmp
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

#############################
###    Generated Files    ###
#############################
get-docker-stacks-upstream-tag:
	@echo $(DOCKER-STACKS-UPSTREAM-TAG)

generate-CUDA:
	bash scripts/get-nvidia-stuff.sh $(tensorflow-CUDA) > $(SRC)/1_CUDA-$(tensorflow-CUDA).Dockerfile
	bash scripts/get-nvidia-stuff.sh    $(pytorch-CUDA) > $(SRC)/1_CUDA-$(pytorch-CUDA).Dockerfile

generate-Spark:
	bash scripts/get-spark-stuff.sh --commit $(COMMIT)  > $(SRC)/2_Spark.Dockerfile

###################################
######    Docker helpers     ######
###################################

pull/%: GITHUB_OUTPUT ?= .tmp/github_output.log
pull/%: DARGS?=
pull/%: REPO?=$(DEFAULT_REPO)
pull/%: TAG?=$(DEFAULT_TAG)
pull/%:
	# End repo with a single slash and start tag with a single colon, if they exist
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	TAG=$$(echo "$(TAG)" | sed 's~^:*~:~' | sed 's~^\s*:*\s*$$~~') &&\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" && \
	echo "Pulling $$IMAGE_NAME" &&\
	docker pull $(DARGS) $$IMAGE_NAME &&\
	echo "image_name=$$IMAGE_NAME" >> $(GITHUB_OUTPUT)

build/%: GITHUB_OUTPUT ?= .tmp/github_output.log
build/%: DIRECTORY?=
build/%: DARGS?=
build/%: REPO?=$(DEFAULT_REPO)
build/%: TAG?=$(DEFAULT_TAG)
build/%: ## build the latest image
	if [ "$(notdir $@)" = "remote-desktop" ]; then \
		BUILDKIT=0; \
	else \
		BUILDKIT=1; \
	fi && \
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::'); \ # End repo with exactly one trailing slash, unless it is empty
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" && \
	DOCKER_BUILDKIT=$$BUILDKIT docker build $(DARGS) --rm --force-rm -t $$IMAGE_NAME ./images/$(DIRECTORY) && \
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
	$(PYTHON) -m pip list

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

dev/%: ARGS?=
dev/%: DARGS?=
dev/%: NB_PREFIX?=$(DEFAULT_NB_PREFIX)
dev/%: PORT?=8888
dev/%: REPO?=$(DEFAULT_REPO)
dev/%: TAG?=$(DEFAULT_TAG)
dev/%: ## run a foreground container for a stack (useful for local testing)
	# End repo with exactly one trailing slash, unless it is empty
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') ;\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" ;\
	echo "\n###############\nLaunching docker container.  Connect to it via http://localhost:$(PORT)$(NB_PREFIX)\n###############\n" ;\
	if xdg-open --version > /dev/null; then\
		( sleep 5 && xdg-open "http://localhost:8888$(NB_PREFIX)" ) & \
	else\
		( sleep 5 && open "http://localhost:8888$(NB_PREFIX)" ) &  \
	fi; \
	docker run -it --rm -p $(PORT):8888 -e NB_PREFIX=$(NB_PREFIX) $(DARGS) $${IMAGE_NAME} $(ARGS)
