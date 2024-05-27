import os
import logging

logger = logging.getLogger(__name__)
logger.setLevel("INFO")

def setup_sasstudio():
  def _get_cmd():
    return [
      "bash",
      "-c",
      "/usr/local/SASHome/studioconfig/sasstudio.sh start && cat"
    ]

  def _rewrite_response(response):
    if 'Location' in response.headers:
      response.headers['Location'] = response.headers['Location'].replace('/SASStudio', os.environ.get('NB_PREFIX') + '/sasstudio/SASStudio/main')

    if 'Set-Cookie' in response.headers:
      response.headers['Set-Cookie'] = response.headers['Set-Cookie'].replace('/SASStudio', os.environ.get('NB_PREFIX') + '/sasstudio/SASStudio/main')

  return {
    "command": _get_cmd,
    "timeout": 60,
    "port": 38080,
    "launcher_entry": {
      "title": "SAS Studio"
    },
    "rewrite_response": _rewrite_response,
  }
