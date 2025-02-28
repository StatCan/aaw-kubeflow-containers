import os
import logging
import subprocess
import socket
import pytest

LOGGER = logging.getLogger(__name__)

# Expected output for version check
EXPECTED_VERSION = "2024.04.2+764 (Chocolate Cosmos) for Ubuntu Jammy"

@pytest.fixture(scope="session", autouse=True)
def start_rstudio_server():
    """Ensure RStudio Server is running before running tests."""
    LOGGER.info("Starting RStudio Server if not already running...")
    subprocess.run(
        ["/usr/lib/rstudio-server/bin/rstudio-server", "start"],
        capture_output=True,
        text=True
    )

@pytest.mark.parametrize("command,expected_keyword,description", [
    (
        ["/usr/lib/rstudio-server/bin/rstudio-server", "version"],
        EXPECTED_VERSION,
        "Test that the rstudio-server version command outputs valid version information."
    ),
])
def test_rstudio_server_version(command, expected_keyword, description):
    """Ensure RStudio Server is running and returns the correct version."""
    LOGGER.info(description)
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
    )
    
    assert result.returncode == 0, (
        f"Command '{' '.join(command)}' failed with exit code {result.returncode}. "
        f"Error output: {result.stderr}"
    )

    output = result.stdout.strip()
    LOGGER.debug(output)
    assert expected_keyword in output, (
        f"Expected keyword '{expected_keyword}' not found in output: {output}"
    )

def test_rstudio_server_port():
    """Check if RStudio Server is listening on port 8787."""
    LOGGER.info("Checking if RStudio Server is listening on port 8787...")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)  # 2-second timeout
    try:
        s.connect(("localhost", 8787))
        s.close()
    except (socket.timeout, ConnectionRefusedError):
        pytest.fail("RStudio Server is not running on port 8787")
