RUN pip --no-cache-dir install --quiet \
      'kfp==1.0.0' \
      'kfp-server-api==1.0.0' \
      'kfp-tekton==0.3.0' \
      'kubeflow-fairing==1.0.1' \
      'ml-metadata==0.24.0' \
      'kubeflow-metadata==0.3.1' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985'

# kfp-azure-databricks needs to be run after kfp
RUN pip --no-cache-dir install --quiet \
      'fire==0.3.1' \
      'git+https://github.com/kubeflow/pipelines@1d86111d8f152d3ed7506ea59cee1bfbc28abbf9#egg=kfp-azure-databricks&subdirectory=samples/contrib/azure-samples/kfp-azure-databricks'
