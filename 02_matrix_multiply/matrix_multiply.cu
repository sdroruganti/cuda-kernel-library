#include <stdio.h>
#include <cuda_runtime_api.h>

#define ROWS 2
#define COLS 2

__global__ void mat_mul(const int *matrix_a, const int *matrix_b){
	int value = 0;
	int row = blockIdx.x;
	int col = threadIdx.x;
        
	if (row >= ROWS || col >= COLS){
		return;
	}

	for (int i = 0; i < COLS; i++){
		value += matrix_a[COLS * row + i] * matrix_b[COLS * i + col];
	}
	printf("Block: %d, Thread: %d, Value: %d\n", blockIdx.x, threadIdx.x, value);

}

int main(){

	int matrix_a[ROWS][COLS] = {
		{2, 4},
		{3, 1}
	};

	int matrix_b[ROWS][COLS] = {
		{6, 2},
		{10,99}
	};

	int *device_a = NULL;
	int *device_b = NULL;

	cudaMalloc((void **)&device_a, sizeof(matrix_a));
	cudaMalloc((void **)&device_b, sizeof(matrix_b));

	cudaMemcpy(device_a, matrix_a, sizeof(matrix_a), cudaMemcpyHostToDevice);
	cudaMemcpy(device_b, matrix_b, sizeof(matrix_b), cudaMemcpyHostToDevice);
	
	mat_mul<<<ROWS, COLS>>>(device_a, device_b);
	
	cudaDeviceSynchronize();
	return 0;
}
