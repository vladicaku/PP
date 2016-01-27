#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
using namespace std;

__device__ int getGlobalIdx_2D_2D()
{
	int blockId = blockIdx.x + blockIdx.y * gridDim.x;
	int threadId = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;
	return threadId;
}

__device__ int getGlobalIdx_1D_1D() 
{
	return blockIdx.x *blockDim.x + threadIdx.x;
}

__global__ void transpose_serial(float *a, float *b, int N)
{
	for (int j=0; j<N; j++)
	{
		for (int i=0; i<N; i++)
		{
			b[j+i*N] = a[i + j*N];
		}
	}
}

__global__ void transpose_row_paralel(float *a, float *b, int N)
{
	int i = threadIdx.x;
	for (int j=0; j<N; j++)
	{
		b[j+i*N] = a[i+j*N];
	}
}

__global__ void transpose_element_paralel(float *a, float *b, int N)
{
	// absolute (real) 2D location
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	b[j+i*N] = a[i+j*N];
}


void test(int g1, int g2, int b1, int b2, int kernel, int matrixSize, bool showOutput)
{
	float *h_a, *h_b;
	float *d_a, *d_b;
	int bytes = matrixSize * matrixSize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);

	// init host arrays
	srand(time(NULL));
	for (int i=0; i<matrixSize; i++) 
	{
		for (int j=0; j<matrixSize; j++)
		{
			h_a[i*matrixSize + j] = 10*i+j;
			h_b[i*matrixSize + j] = 0;
		}
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

	// kernel call
	if (kernel == 0)
	{
		timer.Start();
		transpose_serial<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);
		timer.Stop();
	}
	else if (kernel == 1)
	{	
		timer.Start();
		transpose_row_paralel<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);
		timer.Stop();
	}
	else if (kernel == 2)
	{
		timer.Start();
		transpose_element_paralel<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);	
		timer.Stop();
	}

	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
	if (showOutput) 
	{
		for (int i=0; i<matrixSize; i++)
		{
			for (int j=0; j<matrixSize; j++)
			{
				cout << " " << h_b[i*matrixSize + j];
			}
			cout << endl;
		}
		cout << "\n";
	}
	cudaFree(d_a);
	cudaFree(d_b);
}


void test1(int g1, int g2, int b1, int b2, int matrixSize, bool showOutput)
{
	float *h_a, *d_a;
	float *h_b, *d_b;
	int bytes = matrixSize * matrixSize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);

	// init host arrays
	srand(time(NULL));
	for (int i=0; i<matrixSize; i++) 
	{
		for (int j=0; j<matrixSize; j++)
		{
			h_a[i*matrixSize + j] = 10*i+j;
			h_b[i*matrixSize + j] = 0;
		}
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

	// kernel call
	timer.Start();
	transpose_element_paralel<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);	
	timer.Stop();
	
	cout << timer.Elapsed() << "\t<<<dim3(" << g1 << ", " << g2 << "), dim3(" << b1 << ", " << b2 << ")>>>\n";

	// copy to host
	cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
	if (showOutput) 
	{
		for (int i=0; i<matrixSize; i++)
		{
			for (int j=0; j<matrixSize; j++)
			{
				cout << " " << h_b[i*matrixSize + j];
			}
			cout << endl;
		}
		cout << "\n";
	}
	cudaFree(d_a);
	cudaFree(d_b);
}


int main()
{
	cout << "Matrix size: 10x10" << "\n";
	test(1, 1, 0, 10, true);
	cout << "\n";
	test(1, 10, 1, 10, true);
	cout << "\n";
	test1(5, 5, 2, 2, 10, true); // different test procedure
	cout << "\n";

	cout << "\nMatrix size: 40x40" << "\n";
	test(1, 1, 0, 40, false);
	test(1, 40, 1, 40, false);
	test1(10, 10, 4, 4, 40, false);  // different test procedure
	cout << "\n";

	cout << "\nMatrix size: 100x100" << "\n";
	test(1, 1, 0, 100, false);
	test(1, 100, 1, 100, false);
	test1(25, 25, 4, 4, 100, false);  // different test procedure
	cout << "\n";

    cout << "\nMatrix size: 1024x1024" << "\n";
	test(1, 1, 0, 1024, false);
	test(1, 1024, 1, 1024, false);
	test1(128, 128, 8, 8, 1024, false);  // different test procedure
	test1(32, 32, 32, 32, 1024, false);  // different test procedure
	cout << "\n";


	
	
	scanf("%d", NULL);
    return 0;

}

