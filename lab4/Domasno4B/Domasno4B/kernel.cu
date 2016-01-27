#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include <stdio.h>
#include <stdlib.h> 
#include <iostream>
using namespace std;

const int arraySize = 20480;

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

__global__ void adj_diff_global(float *a, float *b, int len)
{
	int globalId = getGlobalIdx_1D_1D();

	if (globalId < len - 1) 
	{
		b[globalId] = a[globalId+1]-a[globalId];
	}
	else
	{
		b[globalId] = a[globalId];
	}
}

__global__ void adj_diff_global_1(float *a, int len)
{
	int globalId = getGlobalIdx_1D_1D();
	float next, curr;

	if (globalId < len - 1) 
	{
		curr = a[globalId];
		next = a[globalId+1];
		__syncthreads();
		a[globalId] = next-curr;
	}
	else
	{
		curr = a[globalId];
		__syncthreads();
		a[globalId] = curr;
	}
}

__global__ void adj_diff_global_2(float *a, float *b, int len)
{
	int globalId = getGlobalIdx_1D_1D();
	b[globalId] = a[globalId+1]-a[globalId];

	globalId += len / 2;
	if (globalId < len - 1) 
	{
		b[globalId] = a[globalId+1]-a[globalId];
	}
	else
	{
		b[globalId] = a[globalId];
	}
}

__global__ void adj_diff_shared(float *a, float *b, int len)
{
	extern __shared__ float niza[];
	int globalId = getGlobalIdx_1D_1D();
	int inBlockId = threadIdx.x + threadIdx.y * blockDim.x;
	float curr, next;

	niza[inBlockId] = a[globalId];

	if (inBlockId == blockDim.x - 1) {
		niza[inBlockId+1] = a[globalId+1];
	}
	__syncthreads();

	curr = niza[inBlockId];
	next = niza[inBlockId+1];
	__syncthreads();

	if (globalId < len - 1) 
	{	
		niza[inBlockId] = next-curr;
	}
	else
	{	
		niza[inBlockId] = curr;
	}

	b[globalId] = niza[inBlockId];
}

void test1()
{
	float *h_a, *h_b;
	float *d_a, *d_b;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i;
		h_b[i] =0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	adj_diff_global<<<20, 1024>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	adj_diff_global<<<40, 512>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	adj_diff_global<<<80, 256>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	adj_diff_global<<<160, 128>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	adj_diff_global<<<640, 32>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	// copy to host
	/*cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_b[i];
	}	
	cout << "\n";*/
}

void test2(int g, int b)
{
	float *h_a;
	float *d_a;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	adj_diff_global_1<<<g, b>>>(d_a, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	/*cudaMemcpy(h_a, d_a, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_a[i];
	}
	cout << "\n";*/
	
}

void test3(int g, int b)
{
	float *h_a, *h_b;
	float *d_a, *d_b;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i;
		h_b[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	adj_diff_shared<<<g, b, b*sizeof(float) + sizeof(float)>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	/*cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_b[i];
	}
	cout << "\n";*/
}

void test4(int g, int b)
{
	float *h_a, *h_b;
	float *d_a, *d_b;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i;
		h_b[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	adj_diff_global_2<<<g, b>>>(d_a, d_b, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	/*cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_b[i];
	}	
	cout << "\n";*/
}

int main()
{
	// global memory (no sync);
	cout << "Global (no sync)\n----------------------------------\n";
	test1();


	// global memory (with sync);
	cout << "\nGlobal (with sync)\n----------------------------------\n";
	test2(20, 1024);
	test2(40, 512);
	test2(80, 256);
	test2(160, 128);
	test2(640, 32);


	// shared memory
	cout << "\nShared\n----------------------------------\n";
	test3(20, 1024);
	test3(40, 512);
	test3(80, 256);
	test3(160, 128);
	test3(640, 32);
	

	// poveke rabota
	cout << "\nMore work\n----------------------------------\n";
	test4(10, 1024);
	test4(20, 512);
	test4(40, 256);
	test4(80, 128);
	test4(320, 32);

	scanf("%d", NULL);
	return 0;
}