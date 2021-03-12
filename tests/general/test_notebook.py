# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
import logging

LOGGER = logging.getLogger(__name__)

def test_server_alive(container, http_client, url="http://localhost:8888"):
    """Notebook server should eventually appear with a recognizable page."""
    LOGGER.info("Running test_server_alive")
    LOGGER.info("launching the container")
    container.run()
    LOGGER.info(f"accessing {url}")
    resp = http_client.get(url)
    resp.raise_for_status()
    LOGGER.debug(f"got text from url: {resp.text}")

    # Not sure why but some flavors of JupyterLab images don't hit all of these.  
    # Trying to catch several different acceptable looks.
    # Also accepting RStudio
    # TODO: This general test accepts many different images.  
    #       Could refactor to have specific tests that are more pointed
    assert any((
        "<title>JupyterLab" in resp.text,
        "<title>Jupyter Notebook</title>" in resp.text,
        "<title>RStudio:" in resp.text,  # RStudio
        '<html lang="en" class="noVNC_loading">' in resp.text,  # remote-desktop using noVNC
        '<span id="running_list_info">Currently running Jupyter processes</span>' in resp.text,
        )), "Image does not appear to start to JupyterLab page.  Try starting yourself and browsing to it to see what is happening"
