FROM python:3.13-alpine@sha256:18159b2be11db91f84b8f8f655cd860f805dbd9e49a583ddaac8ab39bf4fe1a7

ENV PYTHONUNBUFFERED 1

# Install system dependencies
RUN apk add --no-cache \
    cargo \
    rust \
    gcc \
    musl-dev \
    linux-headers

# Set working directory
RUN adduser -D lightrag
USER lightrag
WORKDIR /home/lightrag

# Set path for user-installed packages
ENV PATH="/home/lightrag/.local/bin:${PATH}"

# Copy requirements first to leverage Docker cache
COPY --chown=lightrag:lightrag ./requirements.txt requirements.txt
RUN pip install --user --no-cache-dir --upgrade -r requirements.txt

# Entry point
ENTRYPOINT ["lightrag-gunicorn"]