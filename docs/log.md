# Daily Log

## Day 0 — Initial Setup and Hardware Sanity

**Date:** July 3, 2026

Set up the initial `cuda-kernel-library` repo and started organizing the environment for learning CUDA. The main goal was to confirm that the local machine can build CUDA code and detect the GPU

## Day 1 — Environment Fixes

**Date:** July 4, 2026

Worked on the CUDA setup after the Ubuntu upgrade. Added a setup script for the NVIDIA driver and CUDA toolkit, and updated it so it can also set the shell environment.

Also ignored the local Makefile since it may change depending on the machine.

## Day 2 — Vector Add

**Date:** July 5, 2026

Added the first real CUDA example, `01_vector_add`. It allocates arrays, runs a simple vector add kernel, and checks the result.

Updated the Makefile so the vector add example can be built and run.

## Day 3 — Profiling

**Date:** July 6, 2026

Added a simple Nsight Systems profiling option to the Makefile. Programs can still run normally, or run with profiling by setting `PROFILE=1`.

Also ignored generated HTML files from local reports.
