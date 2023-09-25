import os
import logging

logger = logging.getLogger(__name__)
logger.setLevel("INFO")

def setup_ompp():

  def _get_cmd():

    return [
      "bash",
      "-c",
      "/usr/local/bin/start-oms.sh"
    ]

  def _rewrite_response(response):
    if 'Location' in response.headers:
      response.headers['Location'] = response.headers['Location'].replace('/SASStudio', os.environ.get('NB_PREFIX') + '/sasstudio/SASStudio')

  return {
    "command": _get_cmd,
    "timeout": 60,
    "port": 4040,
    "launcher_entry": {
      "title": "OpenM++",
            "icon_path": os.path.join(os.getenv("OMPP_INSTALL_DIR", None), "html", "icons", "openmpp.svg"),
    },
    "rewrite_response": _rewrite_response,
  }
