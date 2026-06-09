FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gfortran \
    libgomp1 \
    gnuplot \
    ffmpeg \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN chmod +x Codigo/BashOptN.sh

WORKDIR /app/Codigo
CMD ["bash", "BashOptN.sh"]