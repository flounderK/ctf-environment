FROM ubuntu:20.04

RUN apt update && apt upgrade -y
RUN apt install -y git
WORKDIR /workdir
RUN git clone "https://github.com/flounderK/ctf-environment"
WORKDIR /workdir/ctf-environment

CMD ["./pull_and_install.sh"]
