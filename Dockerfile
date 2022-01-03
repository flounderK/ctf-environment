# syntax=docker/dockerfile:1
FROM ubuntu:20.04

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN echo 'Acquire::http { Proxy "http://dockerhost:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN apt update && apt upgrade -y
RUN apt install -y git sudo curl sed

RUN mkdir -p /workdir/ctf-environment
WORKDIR /workdir/ctf-environment
COPY . /workdir/ctf-environment

RUN echo "ALL       ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -m -s "/bin/bash" --uid=1000 testuser

RUN chown -R testuser:testuser /workdir/ctf-environment
RUN mkdir -p /pyenv_versions_cache
RUN chown -R testuser:testuser /pyenv_versions_cache

USER 1000:1000

CMD ["./install.sh"]
