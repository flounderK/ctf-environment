FROM ubuntu:20.04

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt upgrade -y
RUN apt install -y git sudo curl
RUN mkdir -p /workdir/ctf-environment
WORKDIR /workdir/ctf-environment
COPY . /workdir/ctf-environment
RUN echo "ALL       ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -m -s "/bin/bash" --uid=1000 testuser

USER 1000:1000

CMD ["./install.sh"]
