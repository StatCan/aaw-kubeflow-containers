import logging
import subprocess
import pytest

LOGGER = logging.getLogger(__name__)

EXPECTED = "2024.04.2+764 (Chocolate Cosmos) for Ubuntu Jammy"

@pytest.mark.parametrize("command,expected_keyword,description", [
    (
        "rstudio-server && rstudio-server version",
        EXPECTED,
        "Test that the rstudio-server version command outputs valid version information."
    ),
])
def test_rstudio_server_version(command, expected_keyword, description):
    """Test that rstudio-server version runs successfully and outputs the expected text."""
    LOGGER.info(description)
    result = subprocess.run(
        ["bash", "-c", command],
        capture_output=True,
        text=True,
    )
    # Assert that the command succeeded.
    assert result.returncode == 0, (
        f"Command '{command}' failed with exit code {result.returncode}. "
        f"Error output: {result.stderr}"
    )

    output = result.stdout.strip()  # Strip whitespace for clean comparison
    LOGGER.debug(output)
    # Check that the expected keyword is in the output.
    assert expected_keyword in output, (
        f"Expected keyword '{expected_keyword}' not found in output: {output}"
    )
