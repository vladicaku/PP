#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include <stdio.h>
#include <stdlib.h> 
#include <iostream>
using namespace std;

const int matrixSize = 4;

__global__ void matrix_add_mul(int *a, int *b, int *c, int * d, int width)
{
	int threadId = threadIdx.x + threadIdx.y * blockDim.x;
	int blockId = blockIdx.x + blockIdx.y * gridDim.x;
	int globalId = blockId * blockDim.x * blockDim.y + threadId;
	/*int absX = threadIdx.x + blockDim.x * blockIdx.x;
	int absY = threadIdx.y + blockDim.y * blockIdx.y;*/
	//int globalId = absX + absY * width;
	int absX = globalId % width;
	int absY = globalId / width;

    c[globalId] = a[globalId] + b[globalId];
	//printf("%d ", blockIdx.x);

	for (int i=0; i<width; i++) 
	{
		int sum = a[absY * width + i] * b[absX + i*width];
		d[globalId] += sum;
		
	}


}

int main()
{
	int *h_a, *h_b, *h_c, *h_d;	
	int *d_a, *d_b, *d_c, *d_d;
	int bytes = matrixSize * matrixSize * sizeof(int);
	GpuTimer timer;

	h_a = (int*) malloc(bytes);
	h_b = (int*) malloc(bytes);
	h_c = (int*) malloc(bytes);
	h_d = (int*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);
	cudaMalloc((void **) &d_c, bytes);
	cudaMalloc((void **) &d_d, bytes);

	// init host arrays
	for (int i=0; i<matrixSize*matrixSize; i++) 
	{
			h_a[i] = i+1;
			h_b[i] = i+1;
			h_c[i] = 0;
			h_d[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);
	cudaMemset(d_c, 0, bytes);
	cudaMemset(d_d, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);
	
	
	// kernel call
	timer.Start();
	matrix_add_mul<<<4, 4>>>(d_a, d_b, d_c, d_d, matrixSize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	// copy to host
	cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<matrixSize; i++)
	{
		for (int j=0; j<matrixSize; j++)
		{
		cout << " " << h_c[i*matrixSize + j];
		}
		cout << endl;
	}

	cout << endl << endl;

	cudaMemcpy(h_d, d_d, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<matrixSize; i++)
	{
		for (int j=0; j<matrixSize; j++)
		{
		cout << " " << h_d[i*matrixSize + j];
		}
		cout << endl;
	}
	
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	cudaFree(d_d);
	scanf("%d", NULL);
    return 0;
}

