FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ARG CUDAARCHS="100;90;89;86;80;75"
ARG APP_DIR=/app
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    HF_HOME=/models/.cache/huggingface \
    HF_HUB_ENABLE_HF_TRANSFER=0 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

ENV CUDA_STUBS=/usr/local/cuda/targets/x86_64-linux/lib/stubs
RUN ln -sf ${CUDA_STUBS}/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1
EXPOSE 8080

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3.12 python3.12-venv python3-pip python3.12-dev \
      git ca-certificates wget libopenblas-dev \
      build-essential pkg-config cmake ninja-build && \
    rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip

RUN CMAKE_ARGS="-DGGML_CUDA=on -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS" pip install llama-cpp-python
RUN pip install --no-cache-dir runpod

WORKDIR ${APP_DIR}

COPY handle.py ${APP_DIR}/handle.py
COPY test_input.json ${APP_DIR}/test_input.json
COPY start.sh ${APP_DIR}/start.sh

RUN chmod +x ${APP_DIR}/start.sh
ENTRYPOINT ${APP_DIR}/start.sh
