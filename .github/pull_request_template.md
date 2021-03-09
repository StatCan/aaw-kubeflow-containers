# Description

**What your PR adds/fixes/removes**

# Tests / Quality Checks

## Automated Testing/build and deployment
- [ ] Does the image pass CI successfully (build, pass vulnerability scan, and pass automated test suite)?
- [ ] If new features are added (new image, new binary, etc), have new automated tests been added to cover these?

## Official Languages

- [ ] Test all components JupyterLab components in French

## JupyterLab extensions

- [ ] Does git work?
- [ ] Does VS Code open?

## VS Code tests

- [ ] Can you install extensions?

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
