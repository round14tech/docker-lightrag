FROM python:3.13-slim@sha256:21e39cf1815802d4c6f89a0d3a166cc67ce58f95b6d1639e68a394c99310d2e5

ENV PYTHONUNBUFFERED=1
ENV USER_NAME=lightrag
ENV USER_HOME=/home/${USER_NAME}
ENV WORKING_DIR=${USER_HOME}/rag_storage
ENV INPUT_DIR=${USER_HOME}/inputs
ENV PATH="/root/.cargo/bin:${USER_HOME}/.local/bin:${PATH}"
ENV PYTHONPATH="${USER_HOME}/.local/lib/python3.11/site-packages:${PYTHONPATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Create user and set working directory
RUN useradd --create-home ${USER_NAME}

# Create necessary directories with proper ownership
RUN mkdir -p ${WORKING_DIR} ${INPUT_DIR} && \
    chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}

# Switch to non-root user
USER ${USER_NAME}
WORKDIR ${USER_HOME}

# Copy requirements first to leverage Docker cache
COPY --chown=${USER_NAME}:${USER_NAME} ./requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install --user --no-cache-dir --upgrade -r requirements.txt

# Expose default port
EXPOSE 9621

# Entry point
ENTRYPOINT ["lightrag-gunicorn"]