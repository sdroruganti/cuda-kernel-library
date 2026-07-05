#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "CUDA Kernel Library - GPU Info"
echo "========================================"
echo

echo "===== System ====="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "User: $(whoami)"
echo

if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a 2>/dev/null || true
else
    cat /etc/os-release 2>/dev/null || true
fi

echo
echo "===== Kernel ====="
uname -a

echo
echo "===== NVIDIA Driver / GPU Summary ====="
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi
else
    echo "nvidia-smi not found"
    exit 1
fi

echo
echo "===== GPU Query ====="
nvidia-smi --query-gpu=index,name,uuid,driver_version,cuda_version,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit,pcie.link.gen.current,pcie.link.width.current --format=csv

echo
echo "===== GPU Topology ====="
nvidia-smi topo -m || true

echo
echo "===== NVCC Version ====="
if command -v nvcc >/dev/null 2>&1; then
    nvcc --version
else
    echo "nvcc not found"
fi

echo
echo "===== GCC Version ====="
if command -v gcc >/dev/null 2>&1; then
    gcc --version | head -n 1
else
    echo "gcc not found"
fi

echo
echo "===== G++ Version ====="
if command -v g++ >/dev/null 2>&1; then
    g++ --version | head -n 1
else
    echo "g++ not found"
fi

echo
echo "===== CUDA Toolkit Location ====="
if command -v nvcc >/dev/null 2>&1; then
    which nvcc
    dirname "$(dirname "$(which nvcc)")"
fi

echo
echo "===== Environment ====="
echo "PATH=$PATH"
echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"

echo
echo "===== Done ====="