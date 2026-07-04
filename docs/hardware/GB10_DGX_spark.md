# NVIDIA GB10 / DGX Spark

## Role in this repo

GB10 in DGX Spark is the desktop Grace Blackwell target. It is useful for local
development, correctness testing, small benchmarks, and prototyping kernels
before moving to rack-scale Blackwell systems.

## CUDA target

| Field | Value |
| --- | --- |
| Architecture | NVIDIA Grace Blackwell |
| Compute capability | 12.1 |
| `nvcc` arch | `sm_121` |
| Common systems | NVIDIA DGX Spark and GB10-powered OEM systems |
| Primary workload fit | Local CUDA development, AI inference prototypes, unified-memory experiments, small-to-medium benchmarks |

## Useful specs

| Spec | DGX Spark / GB10 |
| --- | ---: |
| GPU architecture | Blackwell |
| CPU | 20-core Arm, 10 Cortex-X925 + 10 Cortex-A725 |
| Tensor Cores | 5th generation |
| RT Cores | 4th generation |
| Tensor performance | Up to 1 PFLOP FP4 sparse |
| System memory | 128 GB LPDDR5X coherent unified memory |
| Memory interface | 256-bit |
| Memory bandwidth | 273 GB/s |
| Storage | 4 TB NVMe M.2 |
| Networking | 10 GbE, ConnectX-7 NIC at 200 Gbps, Wi-Fi 7 |
| Power supply | 240 W |
| GB10 TDP | 140 W |
| OS | NVIDIA DGX OS |

## Kernel-development notes

- Treat GB10 as a development and validation target, not a replacement for
  H200, GB200, or GB300 performance measurements.
- Build with `-arch=sm_121` for native GB10 cubins.
- The 128 GB coherent memory model is useful for correctness and memory-model
  experiments, but its 273 GB/s bandwidth is much lower than data-center HBM
  systems.
- Keep benchmark problem sizes configurable so the same kernels can run on
  GB10 locally and on larger GPUs later.
- Record CPU architecture and OS details because this system is Arm-based and
  may expose host-side portability issues.

## Benchmark priorities

- Correctness tests for every kernel in the library.
- Small and medium vector, reduction, scan, transpose, and stencil kernels.
- Unified-memory and host/device transfer experiments.
- Quantized inference prototypes using FP4/FP8-style paths where available.
- Build-system coverage for `sm_121`.

## References

- NVIDIA DGX Spark product page: https://www.nvidia.com/en-us/products/workstations/dgx-spark/
- CUDA GPU compute capability table: https://developer.nvidia.com/cuda/gpus
