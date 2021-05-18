# Modified from https://github.com/jupyter/docker-stacks/
import os
import logging

import docker
import pytest
import requests

from requests.packages.urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter


LOGGER = logging.getLogger(__name__)

IMAGE_NAME_ENV_VAR = "IMAGE_NAME"
NB_PREFIX_ENV_VAR = "NB_PREFIX"


@pytest.fixture(scope='session')
def http_client():
    """Requests session with retries and backoff."""
    s = requests.Session()
    retries = Retry(total=9, backoff_factor=1)
    s.mount('http://', HTTPAdapter(max_retries=retries))
    s.mount('https://', HTTPAdapter(max_retries=retries))
    return s


@pytest.fixture(scope='session')
def docker_client():
    """Docker client configured based on the host environment"""
    return docker.from_env()


@pytest.fixture(scope='session')
def image_name():
    """Image name to test"""
    image_name = os.getenv(IMAGE_NAME_ENV_VAR)
    LOGGER.debug(f"Found image_name {image_name} in env variable {IMAGE_NAME_ENV_VAR}")
    if image_name is None or len(image_name) == 0:
        raise ValueError(f"Image name not found in environment variable {IMAGE_NAME_ENV_VAR}.  Did you forget to set it?")
    return image_name


@pytest.fixture(scope='session')
def nb_prefix():
    """
    NB_PREFIX environment variable for test

    Used in the notebook redirect path (eg: localhost:8888/$NB_PREFIX)
    """
    nb_prefix = os.getenv(NB_PREFIX_ENV_VAR)
    LOGGER.debug(f"Found nb_prefix {nb_prefix} in env variable {NB_PREFIX_ENV_VAR}")
    if nb_prefix is None or len(nb_prefix) == 0:
        LOGGER.debug(f"nb_prefix not found in environment variable {NB_PREFIX_ENV_VAR}.  Did you forget to set it?"
                     f"  Setting to empty string")
        nb_prefix = ""
    return nb_prefix


class TrackedContainer(object):
    """Wrapper that collects docker container configuration and delays
    container creation/execution.

    Parameters
    ----------
    docker_client: docker.DockerClient
        Docker client instance
    image_name: str
        Name of the docker image to launch
    nb_prefix: str, optional
        The NB_PREFIX arg, the base url for the server
    **kwargs: dict, optional
        Default keyword arguments to pass to docker.DockerClient.containers.run
    """

    def __init__(self, docker_client, image_name, **kwargs):
        self.container = None
        self.docker_client = docker_client
        self.image_name = image_name
        self.kwargs = kwargs

    def run(self, **kwargs):
        """Runs a docker container using the preconfigured image name
        and a mix of the preconfigured container options and those passed
        to this method.

        Keeps track of the docker.Container instance spawned to kill it
        later.

        Parameters
        ----------
        **kwargs: dict, optional
            Keyword arguments to pass to docker.DockerClient.containers.run
            extending and/or overriding key/value pairs passed to the constructor

        Returns
        -------
        docker.Container
        """
        all_kwargs = {}
        all_kwargs.update(self.kwargs)
        all_kwargs.update(kwargs)
        LOGGER.info(f"Running {self.image_name} with args {all_kwargs} ...")
        self.container = self.docker_client.containers.run(self.image_name, **all_kwargs)
        return self.container

    def remove(self):
        """Kills and removes the tracked docker container."""
        if self.container:
            self.container.remove(force=True)

    def get_cmd(self):
        image = self.docker_client.images.get(self.image_name)
        return image.attrs['Config']['Cmd']


@pytest.fixture(scope='function')
def container(docker_client, image_name, nb_prefix):
    """Notebook container with initial configuration appropriate for testing
    (e.g., HTTP port exposed to the host for HTTP calls).

    Yields the container instance and kills it when the caller is done with it.
    """
    container = TrackedContainer(
        docker_client,
        image_name,
        detach=True,
        ports={
            '8888/tcp': 8888
        },
        environment={'NB_PREFIX': nb_prefix},
    )
    yield container
    container.remove()
