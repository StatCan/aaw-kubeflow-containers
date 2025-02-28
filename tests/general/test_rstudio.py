import logging
import subprocess
import pytest

LOGGER = logging.getLogger(__name__)

EXPECTED = "2024.04.2+764 (Chocolate Cosmos) for Ubuntu Jammy"
IMAGE_NAME = os.getenv("IMAGE_NAME", "default-image-name")  # Use default if not set


@pytest.mark.parametrize("command,expected_keyword,description", [
    (
        f"docker exec {IMAGE_NAME} /usr/lib/rstudio-server/bin/rstudio-server version",
        EXPECTED,
        "Test that the rstudio-server version command outputs valid version information."
    ),
])
def test_rstudio_server_version(command, expected_keyword, description):
    """Ensure rstudio-server is running before checking the version."""
    LOGGER.info("Starting rstudio-server if not already running...")
    subprocess.run(
        ["docker", "exec", IMAGE_NAME, "/usr/lib/rstudio-server/bin/rstudio-server", "start"],
        capture_output=True,
        text=True
    )

    LOGGER.info(description)
    result = subprocess.run(
        command.split(),
        capture_output=True,
        text=True,
    )
    
    assert result.returncode == 0, (
        f"Command '{command}' failed with exit code {result.returncode}. "
        f"Error output: {result.stderr}"
    )

    output = result.stdout.strip()
    LOGGER.debug(output)
    assert expected_keyword in output, (
        f"Expected keyword '{expected_keyword}' not found in output: {output}"
    )
