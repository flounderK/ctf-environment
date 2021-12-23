FROM ubuntu:20.04

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt upgrade -y
RUN apt install -y git sudo curl
RUN mkdir -p /workdir/ctf-environment
WORKDIR /workdir/ctf-environment
COPY . /workdir/ctf-environment

CMD ["./install.sh"]
