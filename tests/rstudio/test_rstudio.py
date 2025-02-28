import logging
import subprocess
import pytest

from helpers import CondaPackageHelper

LOGGER = logging.getLogger(__name__)

EXPECTED = "2024.04.2+764 (Chocolate Cosmos) for Ubuntu Jammy"

@pytest.fixture(scope="function")
def package_helper(container):
    """Return a package helper object that can be used to perform tests on installed packages"""
    return CondaPackageHelper(container)

def _execute_on_container(package_helper, command):
    """Generic function executing a command"""
    LOGGER.debug(f"Running command [{command}] ...")
    return package_helper.running_container.exec_run(command)

def test_rstudio(package_helper):
    result = _execute_on_container(package_helper, ["rstudio-server", "start"])
    LOGGER.info(f"starting up rstudio: {result}")
    assert(result.exit_code==0)

    result = _execute_on_container(package_helper, ["rstudio-server", "version"])
    LOGGER.info(f"rstudio version: {result}")
    assert(EXPECTED in result.output.decode("utf-8"))
 
