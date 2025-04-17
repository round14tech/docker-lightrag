FROM python:3.13-alpine@sha256:18159b2be11db91f84b8f8f655cd860f805dbd9e49a583ddaac8ab39bf4fe1a7

ENV PYTHONUNBUFFERED=1
ENV USER_NAME=lightrag
ENV USER_HOME=/home/${USER_NAME}
ENV WORKING_DIR=${USER_HOME}/rag_storage
ENV INPUT_DIR=${USER_HOME}/inputs
ENV PATH="${USER_HOME}/.local/bin:${PATH}"

# Install system dependencies
RUN apk add --no-cache \
    cargo \
    rust \
    gcc \
    musl-dev \
    linux-headers

# Create user and set working directory
RUN adduser -D ${USER_NAME}

# Create necessary directories with proper ownership
RUN mkdir -p ${WORKING_DIR} ${INPUT_DIR} && \
    chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}

# Switch to non-root user
USER ${USER_NAME}
WORKDIR ${USER_HOME}

# Copy requirements first to leverage Docker cache
COPY --chown=${USER_NAME}:${USER_NAME} ./requirements.txt requirements.txt
RUN pip install --user --no-cache-dir --upgrade -r requirements.txt

# Expose default port
EXPOSE 9621

# Entry point
ENTRYPOINT ["lightrag-gunicorn"]