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
DOCKER-STACKS-UPSTREAM-TAG := 512afd49b925

tensorflow-CUDA := 11.1
pytorch-CUDA    := 11.0

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

.PHONY: clean .output generate-dockerfiles

clean:
	rm -rf $(OUT) $(TMP)

.output:
	mkdir -p $(OUT)/ $(TMP)/

#############################
###    Generated Files    ###
#############################
get-docker-stacks-upstream-tag:
	@echo $(DOCKER-STACKS-UPSTREAM-TAG)

generate-CUDA:
	bash scripts/get-nvidia-stuff.sh $(TensorFlow-CUDA) > $(SRC)/1_CUDA-$(TensorFlow-CUDA).Dockerfile
	bash scripts/get-nvidia-stuff.sh    $(PyTorch-CUDA) > $(SRC)/1_CUDA-$(PyTorch-CUDA).Dockerfile

generate-Spark:
	bash scripts/get-spark-stuff.sh --commit $(COMMIT)  > $(SRC)/2_Spark.Dockerfile

###################################
###### Dockerfile Management ######
###################################

all:
	@echo 'Did you mean to generate all Dockerfiles?  That has been renamed to `make generate-dockerfiles`'

generate-dockerfiles: clean jupyterlab rstudio remote-desktop sas webscraping docker-stacks-datascience-notebook
	@echo "All dockerfiles created."

#############################
###   Bases GPU & Spark   ###
#############################

# Configure the "Bases".
#
pytorch tensorflow: .output
	$(CAT) \
		$(SRC)/0_cpu.Dockerfile \
		$(SRC)/1_CUDA-$($(@)-CUDA).Dockerfile \
		$(SRC)/2_$@.Dockerfile \
	> $(TMP)/$@.Dockerfile

cpu: .output
	$(CAT) $(SRC)/0_$@.Dockerfile > $(TMP)/$@.Dockerfile

################################
###    R-Studio & Jupyter    ###
################################

# Only one output version
rstudio: cpu
	mkdir -p $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@

	$(CAT) \
		$(TMP)/$<.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/5_DB-Drivers.Dockerfile \
		$(SRC)/6_$(@).Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD.Dockerfile \
	>   $(OUT)/$@/Dockerfile

# Only one output version
sas: cpu
	mkdir -p $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@
	cp -r resources/sas/. $(OUT)/$@

	$(CAT) \
		$(TMP)/$<.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/5_DB-Drivers.Dockerfile \
		$(SRC)/6_jupyterlab.Dockerfile \
		$(SRC)/6_$(@).Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD.Dockerfile \
	>   $(OUT)/$@/Dockerfile

# create directories for current images
jupyterlab: pytorch tensorflow cpu

	for type in $^; do \
		mkdir -p $(OUT)/$@-$${type}; \
		cp -r resources/common/. $(OUT)/$@-$${type}/; \
		$(CAT) \
			$(TMP)/$${type}.Dockerfile \
			$(SRC)/3_Kubeflow.Dockerfile \
			$(SRC)/4_CLI.Dockerfile \
			$(SRC)/5_DB-Drivers.Dockerfile \
			$(SRC)/6_$(@).Dockerfile \
			$(SRC)/7_remove_vulnerabilities.Dockerfile \
			$(SRC)/∞_CMD.Dockerfile \
		>   $(OUT)/$@-$${type}/Dockerfile; \
	done

# Remote Desktop
remote-desktop:
	mkdir -p $(OUT)/$@
	echo "REMOTE DESKTOP"
	cp -r scripts/remote-desktop $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@
	cp -r resources/remote-desktop/. $(OUT)/$@

	$(CAT) \
		$(SRC)/0_Rocker.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/6_remote-desktop.Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD_remote-desktop.Dockerfile \
	>   $(OUT)/$@/Dockerfile

# Webscraping
webscraping:
	mkdir -p $(OUT)/$@
	echo "WEBSCRAPING"
	cp -r scripts/remote-desktop $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@
	cp -r resources/remote-desktop/. $(OUT)/$@

	$(CAT) \
		$(SRC)/0_Rocker.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/6_webscraping.Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD_remote-desktop.Dockerfile \
	>   $(OUT)/$@/Dockerfile

# Debugging Dockerfile generator that essentially uses docker-stacks images
# Used for when you need something to build quickly during debugging
docker-stacks-datascience-notebook:
	mkdir -p $(OUT)/$@
	cp -r resources/common/* $(OUT)/$@
	DS_TAG=$$(make -s get-docker-stacks-upstream-tag); \
	echo "FROM jupyter/datascience-notebook:$$DS_TAG" > $(OUT)/$@/Dockerfile; \
	$(CAT) $(SRC)/∞_CMD.Dockerfile >> $(OUT)/$@/Dockerfile

###################################
######    Docker helpers     ######
###################################

pull/%: DARGS?=
pull/%: REPO?=$(DEFAULT_REPO)
pull/%: TAG?=$(DEFAULT_TAG)
pull/%:
	# End repo with a single slash and start tag with a single colon, if they exist
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	TAG=$$(echo "$(TAG)" | sed 's~^:*~:~' | sed 's~^\s*:*\s*$$~~') &&\
	echo "Pulling $${REPO}$(notdir $@)$${TAG}" &&\
	docker pull $(DARGS) "$${REPO}$(notdir $@)$${TAG}"

build/%: DARGS?=
build/%: REPO?=$(DEFAULT_REPO)
build/%: TAG?=$(DEFAULT_TAG)
build/%: ## build the latest image
	# End repo with exactly one trailing slash, unless it is empty
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" && \
	docker build $(DARGS) --rm --force-rm -t $$IMAGE_NAME ./output/$(notdir $@) && \
	echo -n "Built image $$IMAGE_NAME of size: " && \
	docker images $$IMAGE_NAME --format "{{.Size}}" && \
	echo "::set-output name=full_image_name::$$IMAGE_NAME" && \
	echo "::set-output name=image_tag::$(TAG)" && \
	echo "::set-output name=image_repo::$${REPO}"

post-build/%: export REPO?=$(DEFAULT_REPO)
post-build/%: export TAG?=$(DEFAULT_TAG)
post-build/%: export SOURCE_FULL_IMAGE_NAME?=
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
