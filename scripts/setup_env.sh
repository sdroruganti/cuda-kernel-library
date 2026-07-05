#!/usr/bin/env bash
set -euo pipefail

# Host baseline checked on this machine:
#   GPU: NVIDIA RTX A4500
#   Driver packages: 595-open
#   CUDA toolkit: /usr/local/cuda-13.3
#
# Source this file to update the current shell:
#   source scripts/setup_env.sh
#
# Execute it to install/repair packages and print diagnostics:
#   ./scripts/setup_env.sh

NVIDIA_DRIVER_PACKAGE="${NVIDIA_DRIVER_PACKAGE:-nvidia-driver-595-open}"
CUDA_TOOLKIT_PACKAGE="${CUDA_TOOLKIT_PACKAGE:-cuda-toolkit-13-3}"
CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"

APT_PACKAGES=(
  build-essential
  dkms
  "linux-headers-$(uname -r)"
  "${NVIDIA_DRIVER_PACKAGE}"
  "${CUDA_TOOLKIT_PACKAGE}"
  nvidia-modprobe
)

setup_cuda_env() {
  export CUDA_HOME
  export CUDA_PATH="${CUDA_HOME}"

  case ":${PATH}:" in
    *":${CUDA_HOME}/bin:"*) ;;
    *) export PATH="${CUDA_HOME}/bin:${PATH}" ;;
  esac

  local cuda_lib64="${CUDA_HOME}/lib64"
  if [[ -d "${cuda_lib64}" ]]; then
    case ":${LD_LIBRARY_PATH:-}:" in
      *":${cuda_lib64}:"*) ;;
      *) export LD_LIBRARY_PATH="${cuda_lib64}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" ;;
    esac
  fi
}

print_package_state() {
  echo "===== NVIDIA/CUDA package state ====="
  dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package} ${Version}\n' \
    'nvidia-driver-*' 'nvidia-utils-*' 'nvidia-compute-utils-*' \
    'libnvidia-compute-*' 'linux-modules-nvidia-*' \
    'cuda-toolkit*' 'cuda-compiler*' 'cuda-nvcc*' 'cuda-keyring' \
    2>/dev/null | sort || true
  echo

  echo "===== Selected apt candidates ====="
  apt-cache policy \
    "${NVIDIA_DRIVER_PACKAGE}" \
    "${CUDA_TOOLKIT_PACKAGE}" \
    nvidia-modprobe \
    "linux-headers-$(uname -r)" \
    | sed -n '1,220p'
  echo
}

install_packages() {
  sudo apt-get update
  sudo apt-get install -y "${APT_PACKAGES[@]}"
  sudo dpkg --configure -a
  sudo apt-get -f install -y
}

create_nvidia_devices() {
  if command -v nvidia-modprobe >/dev/null 2>&1; then
    sudo nvidia-modprobe -u -c=0 || true
  fi
}

print_runtime_state() {
  echo "===== CUDA environment ====="
  echo "CUDA_HOME=${CUDA_HOME}"
  echo "CUDA_PATH=${CUDA_PATH}"
  echo "PATH=${PATH}"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
  echo

  echo "===== CUDA compiler ====="
  if command -v nvcc >/dev/null 2>&1; then
    command -v nvcc
    nvcc --version
  else
    echo "nvcc not found"
  fi
  echo

  echo "===== NVIDIA driver ====="
  if [[ -r /proc/driver/nvidia/version ]]; then
    cat /proc/driver/nvidia/version
  else
    echo "/proc/driver/nvidia/version not found"
  fi
  echo

  echo "===== NVIDIA devices ====="
  ls -l /dev/nvidia* 2>/dev/null || echo "/dev/nvidia* not found"
  echo

  echo "===== nvidia-smi ====="
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi || {
      echo
      echo "nvidia-smi failed. If packages were just installed or updated, reboot and rerun this script."
      return 1
    }
  else
    echo "nvidia-smi not found"
    return 1
  fi
}

main() {
  setup_cuda_env
  print_package_state
  install_packages
  create_nvidia_devices
  print_runtime_state
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
else
  setup_cuda_env
fi
