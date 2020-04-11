#!/bin/bash

jupyter notebook --notebook-dir=/home/${NB_USER} \
                 --ip=0.0.0.0 \
                 --no-browser \
                 --allow-root \
                 --port=8888 \
                 --NotebookApp.token='' \
                 --NotebookApp.password='' \
                 --NotebookApp.allow_origin='*' \
                 --NotebookApp.base_url=${NB_PREFIX} \
                 --NotebookApp.default_url='/lab'
