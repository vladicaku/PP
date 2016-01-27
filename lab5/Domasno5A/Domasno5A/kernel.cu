#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
#include <time.h> // for cpu 
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
	// absolute (real) 2D location, invalid code, works only for 1 block
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;


	//b[j + i * N] = a[i + j * N];
	// small fix
	if (i <= N && j <= N)
	{
		b[j + i * N] = a[i + j * N];
	}
	
}

void transpose_cpu(float *a, float *b, int N)
{
	for (int j=0; j<N; j++)
	{
		for (int i=0; i<N; i++)
		{
			b[j+i*N] = a[i + j*N];
		}
	}
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
			h_a[i*matrixSize + j] = 10*i+j+1;
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
		cout << "CUDA serial" << "\n";
	}
	else if (kernel == 1)
	{	
		timer.Start();
		transpose_row_paralel<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);
		timer.Stop();
		cout << "CUDA row parallel" << "\n";
	}
	else if (kernel == 2)
	{
		timer.Start();
		transpose_element_paralel<<<dim3(g1, g2), dim3(b1, b2)>>>(d_a, d_b, matrixSize);	
		timer.Stop();
		cout << "CUDA element parallel" << "\n";
	}
	else if (kernel == 3)
	{
		clock_t begin, end;
		double time_spent;

		/*
		// gettimeofday() isn't guaranteed to be monotonic
		timeval tm1;
		timeval tm2;
		gettimeofday(&tm1, NULL);
		transpose_cpu(h_a, h_b, matrixSize);
		gettimeofday(&tm2, NULL);
		unsigned long long time_spent = 1000 * (tm2.tv_sec - tm1.tv_sec) + (tm2.tv_usec - tm1.tv_usec) / 1000;
		printf("%llu ms\n", t);
		*/

		
		begin = clock();
		transpose_cpu(h_a, h_b, matrixSize);
		end = clock();
		//time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		//time_spent = (double)(end - begin);
		time_spent = ((double) (end - begin) * 1000.0) / CLOCKS_PER_SEC;
		

		cout << "CPU serial" << "\n";
		//printf("Time elapsed in ms: %f \n", time_spent);
		cout << time_spent << "\n";

		// show output
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

		//cout << h_b[0] << " " << h_b[matrixSize * matrixSize - 1] << "\n";
		return;

	}

	cout << timer.Elapsed() << "\t<<<dim3(" << g1 << ", " << g2 << "), dim3(" << b1 << ", " << b2 << ")>>>\n";

	// copy to host
	cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);

	//cout << h_b[0] << " " << h_b[matrixSize * matrixSize - 1] << "\n";;

	// show output
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
	// g1, g2, b1, b2, kernel, matrixSize, showOutput
	cout << "--------------------- Basic testing ---------------------" << "\n";
	cout << "Matrix size: 4x4" << "\n" << "\n";
	test(1, 1, 1, 1, 0, 4, true); // cuda serial
	cout << "\n";
	test(1, 1, 4, 1, 1, 4, true); // cuda row paralel
	cout << "\n";
	test(2, 2, 2, 2, 2, 4, true); // cuda element paralel
	cout << "\n";
	test(1, 1, 1, 1, 3, 4, true); // CPU serial

	cout << "\n";
	cout << "Matrix size: 40x40" << "\n" << "\n";
	test(1, 1, 1, 1, 0, 40, false); // cuda serial
	cout << "\n";
	test(1, 1, 40, 1, 1, 40, false); // cuda row paralel
	cout << "\n";
	test(4, 4, 10, 10, 2, 40, false); // cuda element paralel
	cout << "\n";
	test(1, 1, 1, 1, 3, 40, false); // CPU serial


	// Best grid and block size testing
	cout << "\n";
	cout << "--------------------- Grid and block size testing ---------------------" << "\n";
	cout << "\n";
	cout << "Matrix size: 100x100" << "\n" << "\n";
	test(4, 4, 25, 25, 2, 40, false); // cuda element paralel
	cout << "\n";
	test(5, 5, 20, 20, 2, 40, false); // cuda element paralel
	cout << "\n";
	test(10, 10, 10, 10, 2, 40, false); // cuda element paralel
	cout << "\n";
	test(20, 20, 5, 5, 2, 40, false); // cuda element paralel


	// Extreme testing
	// Tested 
	cout << "\n";
	cout << "--------------------- Extreme ---------------------" << "\n";
	cout << "\n";
	cout << "Matrix size: 500x500" << "\n" << "\n";
	test(50, 50, 10, 10, 2, 500, false); // cuda element paralel
	cout << "\n";
	test(1, 1, 1, 1, 3, 500, false); // CPU serial
	
	cout << "\n";
	cout << "Matrix size: 1000x1000" << "\n" << "\n";
	test(50, 50, 20, 20, 2, 1000, false); // cuda element paralel
	cout << "\n";
	test(1, 1, 1, 1, 3, 1000, false); // CPU serial

	
	scanf("%d", NULL);
    return 0;
}

