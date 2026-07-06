// vector_add

#include <cstdlib>
#include <cassert>
#include <iostream>

__global__ void vectorAdd(int *a, int *b, int *c, int N){
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	if (tid < N){
		c[tid] = a[tid] + b[tid];
	}
}

void init_array(int *a, int N){
	for (int i = 0; i < N; i++){
		a[i] = rand() % 100;
	}
}

void verify_solution(int *a, int *b, int *c, int N){
	for (int i = 0; i < N; i++){
		assert(a[i] + b[i] == c[i]);
	}
}

int main(){
	int N = 1 << 20;
	size_t bytes = N * sizeof(bytes);
	
	int *a, *b, *c;
	cudaMallocManaged(&a, bytes);
	cudaMallocManaged(&b, bytes);
	cudaMallocManaged(&c, bytes);

	init_array(a, N);
	init_array(b, N);

	int THREADS = 256; // Should define as multiples of 32 due to the CUDA warp size
	int BLOCKS = (N + THREADS - 1) / THREADS;

	vectorAdd<<<BLOCKS, THREADS, 0, 0>>>(a, b, c, N);
	cudaDeviceSynchronize(); // Needed for synchronizing. Also needed as the program is using cudaMallocManaged

	verify_solution(a, b, c, N);

	std::cout << "VECTOR ADD COMPLETE" << std::endl;

	return 0;

}
