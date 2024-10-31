# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
import logging

LOGGER = logging.getLogger(__name__)


def test_server_alive(container, http_client, url="http://localhost:8888"):
    """Notebook server should eventually appear with a recognizable page."""

    # Redirect url to NB_PREFIX if it is set in the container environment
    url = "{}{}/".format(url, container.kwargs['environment']['NB_PREFIX'])

    LOGGER.info("Running test_server_alive")
    LOGGER.info("launching the container")
    container.run()
    LOGGER.info(f"accessing {url}")
    resp = http_client.get(url)
    resp.raise_for_status()
    LOGGER.debug(f"got text from url: {resp.text}")

    # Define various possible expected texts (this catches different expected outcomes like a JupyterLab interface,
    # RStudio, etc.).  If any of these pass, the test passes
    assertion_expected_texts = [
        "<title>JupyterLab",
        "<title>Jupyter Notebook</title>",
        "<title>RStudio</title>",
        '<html lang="en" class="noVNC_loading">',  # Remote desktop
        '<html lang="fr" class="noVNC_loading">',  # Remote desktop
        '<span id="running_list_info">Currently running Jupyter processes</span>',
    ]
    assertions = [s in resp.text for s in assertion_expected_texts]

    # Log assertions to screen for easier debugging
    LOGGER.debug("Status of tests look for that indicate notebook is up:")
    for i, (text, assertion) in enumerate(zip(assertion_expected_texts, assertions)):
        LOGGER.debug(f"{i}: '{text}' in resp.text = {assertion}")

    assert any(assertions), "Image does not appear to start to JupyterLab page.  " \
                            "Try starting yourself and browsing to it to see what is happening"
