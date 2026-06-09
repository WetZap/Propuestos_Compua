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

RUN sed -i 's/gfortran /gfortran -ffree-line-length-none /g' Code/Bash.sh

RUN chmod +x Code/Bash.sh

WORKDIR /app/Code
CMD ["bash", "Bash.sh"]