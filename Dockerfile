## pull official base image
#FROM python:3.10-slim-buster
#
## set work directory
#WORKDIR /usr/src/app
#
## set environment variables
#ENV PYTHONDONTWRITEBYTECODE=1
#ENV PYTHONUNBUFFERED=1
#
## install mysql dependencies
##RUN apt-get update
##RUN apt-get install gcc default-libmysqlclient-dev -y
#
## Install system dependencies
#RUN apt-get update && apt-get install -y \
#    gcc \
#    libmariadb-dev \
#    pkg-config \
#    && rm -rf /var/lib/apt/lists/*
#
#
## install dependencies
#RUN pip install -U pip setuptools wheel
#RUN apt-get update && \
#    apt-get install -y dos2unix netcat-openbsd && \
#    rm -rf /var/lib/apt/lists/*
#
#COPY ./requirements.txt .
#RUN pip install -r requirements.txt --no-cache-dir
#
## copy project
## COPY . .          # This image is only contain requirements file not the codebase .
#
## Convert plain text files from Windows or Mac format to Unix
#COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#RUN apt-get install dos2unix
#RUN dos2unix --newfile docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#
## Make entrypoint executable
#RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#
## Entrypoint dependencies
#RUN apt-get install netcat -y
#
## run entrypoint.sh
#ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]






# =======================
# Stage 1: Build Layer
# =======================
FROM python:3.10 AS build

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install build dependencies
RUN apt-get update && \
    apt-get install -y gcc libmariadb-dev dos2unix && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entrypoint script and convert to Unix format
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN dos2unix /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# ============================
# Stage 2: Runtime Layer
# ============================
FROM python:3.10-slim

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install only runtime deps (smaller footprint)
RUN apt-get update && \
    apt-get install -y libmariadb-dev netcat-openbsd dos2unix && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages and entrypoint from builder
COPY --from=build /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=build /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Copy the entrypoint again to ensure permissions and format
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]



