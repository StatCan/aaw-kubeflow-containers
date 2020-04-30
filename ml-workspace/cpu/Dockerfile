FROM mltooling/ml-workspace:0.9.1

ENV \
    NB_USER="joyvan" \
    USER_GID=1000 \
    XDG_CACHE_HOME="/home/joyvan/.cache/" \
    HOME="/home/joyvan" \
    WORKSPACE_PORT=8888

COPY init.sh /
COPY resources/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY resources/supervisor/programs /etc/supervisor/conf.d/
COPY resources/tools/ $RESOURCES_PATH/tools

RUN groupadd -g 1000 joyvan && useradd -m -u 1000 -g joyvan joyvan && \
    cp -R /root/. /home/joyvan && \
    chown -R joyvan:joyvan /home/joyvan && \
    chmod -R 555 $RESOURCES_PATH/tools && \
    chown -R joyvan:joyvan $XDG_CACHE_HOME && \
    chown -R joyvan:joyvan $CONDA_DIR && \
    mkdir /var/run/supervisord && \ 
    chown -R joyvan:joyvan /var/run/supervisord && \
    chown -R joyvan:joyvan /usr/local && \
    chown -R joyvan:joyvan /usr/share && \
    chown -R joyvan:joyvan /etc/nginx && \
    chown -R joyvan:joyvan /etc/supervisor && \
    chown -R joyvan:joyvan /var/log/supervisor/ && \
    chown -R joyvan:joyvan /var/log/nginx/ && \
    $RESOURCES_PATH/tools/r-runtime.sh && \
    $RESOURCES_PATH/tools/r-studio-desktop.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    echo "joyvan ALL=(ALL) NOPASSWD: /resources/tools/, /usr/sbin/cron, /usr/sbin/netdata, /usr/sbin/rsyslogd, /usr/sbin/xrdp, /usr/sbin/sslh, /usr/sbin/sshd" >> /etc/sudoers.d/joyvan && \
    printf "export ZSH=\"/home/joyvan/.oh-my-zsh\"\nZSH_THEME=\"avit\"\nDISABLE_AUTO_UPDATE=\"true\"\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=245\"\nplugins=(git k extract colorize pip npm zsh-256color supervisor command-not-found autojump colored-man-pages git-flow git-extras httpie python zsh-autosuggestions history-substring-search zsh-completions zsh-syntax-highlighting)\nsource \$ZSH/oh-my-zsh.sh\nLS_COLORS=\"\"\nexport LS_COLORS\n" > /home/joyvan/.zshrc && \
    chmod +x /init.sh

WORKDIR $HOME

USER joyvan

EXPOSE 8888

CMD ["/init.sh"]
