FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gfortran \
    libgomp1 \
    gnuplot \
    ffmpeg \
    bash \
    magick \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN chmod +x Code/BashOptN.sh

WORKDIR /app/Code
CMD ["bash", "BashOptN.sh"]