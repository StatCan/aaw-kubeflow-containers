FROM mltooling/ml-workspace-gpu

COPY init.sh /

RUN chmod +x /init.sh

ENV WORKSPACE_PORT="8888"

EXPOSE 8888

CMD ["/init.sh"]
