#include <cuda_runtime.h>

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>

#define CUDA_CHECK(call)                                                       \
    do {                                                                       \
        cudaError_t err__ = (call);                                            \
        if (err__ != cudaSuccess) {                                            \
            std::fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__,        \
                         __LINE__, cudaGetErrorString(err__));                 \
            return EXIT_FAILURE;                                               \
        }                                                                      \
    } while (0)

__global__ void saxpy_kernel(const float* x, const float* y, float* out,
                             float alpha, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        out[idx] = alpha * x[idx] + y[idx];
    }
}

static void print_device_properties(int device_id,
                                    const cudaDeviceProp& props) {
    std::printf("Device %d: %s\n", device_id, props.name);
    std::printf("  Compute capability: %d.%d\n", props.major, props.minor);
    std::printf("  SM count: %d\n", props.multiProcessorCount);
    std::printf("  Global memory: %.2f GiB\n",
                static_cast<double>(props.totalGlobalMem) /
                    (1024.0 * 1024.0 * 1024.0));
    std::printf("  Shared memory/block: %zu bytes\n",
                static_cast<size_t>(props.sharedMemPerBlock));
    std::printf("  Registers/block: %d\n", props.regsPerBlock);
    std::printf("  Warp size: %d\n", props.warpSize);
    std::printf("  Max threads/block: %d\n", props.maxThreadsPerBlock);
    std::printf("  Max grid size: %d x %d x %d\n", props.maxGridSize[0],
                props.maxGridSize[1], props.maxGridSize[2]);
    std::printf("  Memory bus width: %d bits\n", props.memoryBusWidth);
}

int main() {
    int device_count = 0;
    cudaError_t device_status = cudaGetDeviceCount(&device_count);
    if (device_status == cudaErrorNoDevice) {
        std::fprintf(stderr, "No CUDA-capable devices found.\n");
        return EXIT_FAILURE;
    }
    if (device_status != cudaSuccess) {
        std::fprintf(stderr, "Unable to query CUDA devices: %s\n",
                     cudaGetErrorString(device_status));
        return EXIT_FAILURE;
    }
    if (device_count == 0) {
        std::fprintf(stderr, "No CUDA devices found.\n");
        return EXIT_FAILURE;
    }

    int runtime_version = 0;
    int driver_version = 0;
    CUDA_CHECK(cudaRuntimeGetVersion(&runtime_version));
    CUDA_CHECK(cudaDriverGetVersion(&driver_version));

    std::printf("CUDA runtime version: %d.%d\n", runtime_version / 1000,
                (runtime_version % 1000) / 10);
    std::printf("CUDA driver version: %d.%d\n", driver_version / 1000,
                (driver_version % 1000) / 10);
    std::printf("CUDA devices found: %d\n\n", device_count);

    for (int device_id = 0; device_id < device_count; ++device_id) {
        cudaDeviceProp props{};
        CUDA_CHECK(cudaGetDeviceProperties(&props, device_id));
        print_device_properties(device_id, props);
        std::printf("\n");
    }

    CUDA_CHECK(cudaSetDevice(0));

    constexpr int n = 1 << 20;
    constexpr float alpha = 2.0f;
    constexpr int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    const size_t bytes = n * sizeof(float);

    std::vector<float> h_x(n);
    std::vector<float> h_y(n);
    std::vector<float> h_out(n, 0.0f);

    for (int i = 0; i < n; ++i) {
        h_x[i] = static_cast<float>(i % 100) * 0.25f;
        h_y[i] = static_cast<float>(i % 37) * 0.5f;
    }

    float* d_x = nullptr;
    float* d_y = nullptr;
    float* d_out = nullptr;

    CUDA_CHECK(cudaMalloc(&d_x, bytes));
    CUDA_CHECK(cudaMalloc(&d_y, bytes));
    CUDA_CHECK(cudaMalloc(&d_out, bytes));

    CUDA_CHECK(cudaMemcpy(d_x, h_x.data(), bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_y, h_y.data(), bytes, cudaMemcpyHostToDevice));

    cudaEvent_t start = nullptr;
    cudaEvent_t stop = nullptr;
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));

    CUDA_CHECK(cudaEventRecord(start));
    saxpy_kernel<<<blocks, threads>>>(d_x, d_y, d_out, alpha, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));

    float elapsed_ms = 0.0f;
    CUDA_CHECK(cudaEventElapsedTime(&elapsed_ms, start, stop));

    CUDA_CHECK(cudaMemcpy(h_out.data(), d_out, bytes, cudaMemcpyDeviceToHost));

    for (int i = 0; i < n; ++i) {
        const float expected = alpha * h_x[i] + h_y[i];
        if (std::fabs(h_out[i] - expected) > 1e-5f) {
            std::fprintf(stderr,
                         "Validation failed at index %d: got %.8f, expected "
                         "%.8f\n",
                         i, h_out[i], expected);
            cudaEventDestroy(start);
            cudaEventDestroy(stop);
            cudaFree(d_x);
            cudaFree(d_y);
            cudaFree(d_out);
            return EXIT_FAILURE;
        }
    }

    std::printf("Kernel check: PASS (%d elements, %.3f ms)\n", n, elapsed_ms);

    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));
    CUDA_CHECK(cudaFree(d_x));
    CUDA_CHECK(cudaFree(d_y));
    CUDA_CHECK(cudaFree(d_out));
    CUDA_CHECK(cudaDeviceSynchronize());

    std::printf("CUDA sanity check: PASS\n");
    return EXIT_SUCCESS;
}
