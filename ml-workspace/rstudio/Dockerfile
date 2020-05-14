FROM k8scc01covidacr.azurecr.io/ml-workspace-base:master

RUN sudo $RESOURCES_PATH/tools/r-runtime.sh && \
    sudo $RESOURCES_PATH/tools/r-studio-desktop.sh 

CMD ["/init.sh"]
