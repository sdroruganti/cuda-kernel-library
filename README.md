# cuda-kernel-library

A collection of CUDA kernels, benchmarks, notes, and PyTorch extensions.

## Projects

| Project | CUDA concept |
| --- | --- |
| `00_sanity` | Device discovery and a SAXPY smoke test |
| `01_vector_add` | Basic one-dimensional indexing |
| `02_matrix_multiply` | Naive matrix multiplication |
| `03_reduction` | Reduction (planned) |
| `04_matrix_transpose` | Matrix transpose (planned) |
| `05_softmax` | Softmax (planned) |
| `06_layernorm` | Layer normalization (planned) |
| `07_sobel_filter` | Sobel image filter (planned) |
| `08_histogram` | Histogram (planned) |
| `09_convolution_1d` | One-dimensional convolution (planned) |
| `10_tiled_matrix_multiply` | Tiled matrix multiplication (planned) |

Each example is a standalone CUDA program. Build and run a project with:

```bash
nvcc -O2 08_histogram/histogram.cu -o histogram
./histogram
```

All code is tested on the following hardware:

- GB10
- A4500
