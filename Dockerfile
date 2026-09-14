FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install --yes --no-install-recommends sudo ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash tester && \
    echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester && \
    chmod 0440 /etc/sudoers.d/tester

USER tester
WORKDIR /home/tester

COPY --chown=tester:tester . /home/tester/myconfig-src

ENV MYCONFIG_SOURCE_PATH=/home/tester/myconfig-src \
    MYCONFIG_SUDOER=1 \
    MYCONFIG_INSTALL_PACKAGES=1 \
    MYCONFIG_INSTALL_ZSH=1 \
    MYCONFIG_INSTALL_VIM=1 \
    MYCONFIG_INSTALL_TMUX=1

CMD ["bash", "/home/tester/myconfig-src/install.sh"]
