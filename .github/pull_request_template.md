# Description

**What your PR adds/fixes/removes**

# Tests / Quality Checks

## Automated Testing/build and deployment
- [ ] Does the image pass CI successfully (build, pass vulnerability scan, and pass automated test suite)?
- [ ] If new features are added (new image, new binary, etc), have new automated tests been added to cover these?
- [ ] If new features are added that require in-cluster testing (e.g. a new feature that needs to interact with kubernetes), have you added the `auto-deploy` tag to the PR before pushing in order to build and push the image to ACR so you can test it in cluster as a custom image?

## JupyterLab extensions

- [ ] Are all extensions "enabled" (`jupyter labextension list` from inside the notebook)?

## VS Code tests

- [ ] Does VS Code open?
- [ ] Can you install extensions?

## Code review

- [ ] Have you added the `auto-deploy` tag to your PR before your most recent push to this repo?  This causes CI to build the image and push to our ACR, letting reviewers access the built image without having to create it themselves
- [ ] Have you chosen a reviewer, attached them as a reviewer to this PR, and messaged them with the SHA-pinned image name for the final image to test (e.g. `k8scc01covidacr.azurecr.io/machine-learning-notebook-cpu:746d058e2f37e004da5ca483d121bfb9e0545f2b`)?

## Port/proxy

Copy paste this into a python notebook:

```python
import http.server
import socketserver
from http import HTTPStatus


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'Hello world')


httpd = socketserver.TCPServer(('', 8000), Handler)
httpd.serve_forever()
```

Open a tab with `https://kubeflow.covid.cloud.statcan.ca/notebook/$NAMESPACE/$SERVER/proxy/8000`
