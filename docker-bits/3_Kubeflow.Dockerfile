# DEBUG
RUN pip3 -V
RUN pip3 --no-cache-dir install \
      'ml-metadata==0.27.0'

RUN pip3 --no-cache-dir install --quiet \
      'git+https://github.com/statcan/kubeflow-pipelines@b47c8de7f2915722c5c91bf3b1c7d54b946ef2a6#subdirectory=sdk/python/' \
      'kfp-server-api==1.3.0' \      
      'kubeflow-fairing==1.0.2' \
      'kubeflow-metadata==0.2.0' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985'

# kfp-azure-databricks needs to be run after kfp
RUN pip3 --no-cache-dir install --quiet \
      'fire==0.3.1' \
      'git+https://github.com/kubeflow/pipelines@1d86111d8f152d3ed7506ea59cee1bfbc28abbf9#egg=kfp-azure-databricks&subdirectory=samples/contrib/azure-samples/kfp-azure-databricks'
