# Install PyTorch
RUN conda create -n torch python=3.7 && \
    conda install -n torch --quiet --yes -c pytorch \
      'pytorch==1.6.0' \
      'torchvision==0.7.0' \
      'ipykernel==5.3.4' \
    && \
    conda install -n torch --quiet --yes -c pytorch \
      'torchtext==0.7.0' \
    && \
    conda activate torch \
    && \
    python -c 'import torchvision; torchvision.models.resnet18(pretrained=True); torchvision.models.resnet34(pretrained=True); torchvision.models.resnet50(pretrained=True); torchvision.models.resnet101(pretrained=True); torchvision.models.resnet152(pretrained=True); torchvision.models.squeezenet1_0(pretrained=True); torchvision.models.squeezenet1_1(pretrained=True); torchvision.models.densenet121(pretrained=True); torchvision.models.densenet161(pretrained=True); torchvision.models.densenet169(pretrained=True); torchvision.models.densenet201(pretrained=True); torchvision.models.inception_v3(pretrained=True); torchvision.models.googlenet(pretrained=True); torchvision.models.shufflenet_v2_x0_5(pretrained=True); torchvision.models.shufflenet_v2_x1_0(pretrained=True); torchvision.models.shufflenet_v2_x1_5(pretrained=True); torchvision.models.shufflenet_v2_x2_0(pretrained=True); torchvision.models.mobilenet_v2(pretrained=True); torchvision.models.resnext50_32x4d(pretrained=True); torchvision.models.resnext101_32x8d(pretrained=True); torchvision.models.wide_resnet50_2(pretrained=True); torchvision.models.wide_resnet101_2(pretrained=True); torchvision.models.mnasnet0_5(pretrained=True); torchvision.models.mnasnet0_75(pretrained=True); torchvision.models.mnasnet1_0(pretrained=True); torchvision.models.mnasnet1_3(pretrained=True); torchvision.models.segmentation.fcn_resnet50(pretrained=True); torchvision.models.segmentation.fcn_resnet101(pretrained=True); torchvision.models.segmentation.deeplabv3_resnet50(pretrained=True); torchvision.models.segmentation.deeplabv3_resnet50(pretrained=True); torchvision.models.segmentation.deeplabv3_resnet101(pretrained=True); torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=True); torchvision.models.detection.retinanet_resnet50_fpn(pretrained=True); torchvision.models.detection.maskrcnn_resnet50_fpn(pretrained=True); torchvision.models.detection.keypointrcnn_resnet50_fpn(pretrained=True); torchvision.models.video.r3d_18(pretrained=True); torchvision.models.video.mc3_18(pretrained=True); torchvision.models.video.r2plus1d_18(pretrained=True)' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
