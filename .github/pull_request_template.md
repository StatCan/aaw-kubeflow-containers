# Description

**What your PR adds/fixes/removes**

# Tests

## Hello Worlds

- [ ] Does R work in a notebook?
- [ ] Does Python work in a notebook?
- [ ] Does Julia work in a notebook?

## Imports

- [ ] Does PyTorch run
- [ ] Does Tensorflow run

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

- [ ] Does "Hello world" work?
