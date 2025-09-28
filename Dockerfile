FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    HF_HOME=/models/.cache/huggingface \
    HF_HUB_ENABLE_HF_TRANSFER=0 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

EXPOSE 8080

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3.12 python3.12-venv python3-pip python3.12-dev \
      git ca-certificates wget libopenblas-dev \
      build-essential pkg-config cmake ninja-build && \
    rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip

RUN export CMAKE_ARGS="-DGGML_CUDA=on -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS -DCMAKE_CUDA_ARCHITECTURES=${CUDAARCHS}"; \
    pip install --no-cache-dir --upgrade pip && \
    FORCE_CMAKE=1 pip install --no-cache-dir llama-cpp-python runpod;

COPY handle.py test_input.json start.sh /
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
