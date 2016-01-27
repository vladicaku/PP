#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h" // custom lib
#include <stdio.h>
#include <stdlib.h> 
#include <iostream>
#include <math.h>
using namespace std;

// Will be used to determinate the total number of blocks for the kernel. 
// The number of blocks is going to be		totalNumberOfBlocks = nVertices / NUMBER_OF_THREADS_PER_BLOCK.
// If nVertices % NUMBER_OF_THREADS_PER_BLOCK > 0, then one extra block will be lunched,
// i.e totalNumberOfBlocks will be increased by 1, totalNumberOfBlocks++.
const int NUMBER_OF_THREADS_PER_BLOCK = 128;

// Indicates that there are changes in the depths array (new depth is added in the array).
// If there are no changes, the loop in the main() will stop. This means that all 
// of the nodes in the graph are visited.
__device__ int d_hasChanges = 0;

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

__global__ void bfs(int *vertices, int *edges, int *depths, int *frontiers, int n) {
	int threadId = getGlobalIdx_2D_2D();
	int numberOfEdges;
	int firstEdgePosition;

	//printf("TID: %d\n", threadId);

	if ((threadId < n) && (frontiers[threadId] == 1)) {
		frontiers[threadId] = 0;

		numberOfEdges = vertices[threadId + 1] - vertices[threadId];
		firstEdgePosition = vertices[threadId];

		//printf("TID: %d - numberOfEdges = %d\n", threadId, numberOfEdges);
		//printf("TID: %d - firstEdgePosition = %d\n", threadId, firstEdgePosition);
		int myDepht = depths[threadId];

		for (int i=0; i<numberOfEdges; i++) {
			int edgePosition = firstEdgePosition + i;
			int nodePosition = edges[edgePosition];

			//printf("TID: %d - nodePosition: %d; level: %d\n", threadId, nodePosition, level);
			//printf("TID: %d - depth[%d] = %d\n", threadId, nodePosition, depths[nodePosition]);
			if (depths[nodePosition] == -1) {
				depths[nodePosition] = myDepht + 1;
				frontiers[nodePosition]  = 1;
				d_hasChanges = 1;
				//printf("TID: %d - hasChanges: true; nodePosition: %d;  level: %d\n", threadId, nodePosition, level);
			}
		}
		
	}
}

// Generates a graph in form of rings.
// Each vertex has equal number of edges.
// File format:
// #ofVertices
// #ofEdges
// #ofEdges for current node
// currentNode endNode
// .
// .
// #ofEdges for current node
// currentNode endNode
// currentNode endNode
// .
// .
void generate(int level, int numberOfEdgesPerVertex) {
	printf("Generating input file ....\n");
	FILE *fp;
	fp = fopen("D:\\input.txt", "w+");
	int counter = 1;

	// calculate the total number of edges
	int totalNumberOfEdges = 0;
	for (int i=1; i<=level; i++) {
		totalNumberOfEdges += (int)(pow(numberOfEdgesPerVertex, i));
	}

	// write number of vertices
	fprintf(fp, "%d\n", totalNumberOfEdges + 1);
	// write number of edges
	fprintf(fp, "%d\n", totalNumberOfEdges);

	int currentVertex = -1;
	for (int i=0; i<totalNumberOfEdges; i++) {
		if (i % numberOfEdgesPerVertex == 0) {
			currentVertex++;
			fprintf(fp, "%d\n", numberOfEdgesPerVertex);
		}
		fprintf(fp, "%d %d\n", currentVertex, i+1);
	}

	for (int i=0; i<(int)(pow(numberOfEdgesPerVertex, level)); i++) {
		fprintf(fp,"0\n");
	}

	fclose(fp);
}

int main(int argc, char* argv[])
{
	// TODO
	// implement CLI arguments and print usage
	generate(2, 1000);
	GpuTimer timer;
	FILE *fp, *fp1;
	int nVertices = 0, nEdges = 0;
	int *h_vertices, *h_edges, *h_depths, *h_frontiers;
	int *d_vertices, *d_edges, *d_depths, *d_frontiers;

	// read from file
	fp = fopen("D:\\input.txt", "r");
	fscanf(fp, "%d", &nVertices);
	fscanf(fp, "%d", &nEdges);

	// set sizes
	int verticesSize = (nVertices + 1) * sizeof(int);
	int edgesSize = nEdges * sizeof(int);
	int depthsSize = nVertices * sizeof(int);
	int frontiersSize = nVertices * sizeof(int);

	// allocate host memory
	printf("Allocate host memory ...\n");
	h_vertices = (int*) malloc(verticesSize);
	h_edges = (int*) malloc(edgesSize);
	h_depths = (int*) malloc(depthsSize);
	h_frontiers = (int*) malloc(frontiersSize);
	
	// allocate device memory
	printf("Allocate device memory memory ...\n");
	cudaMalloc((void **) &d_vertices, verticesSize);
	cudaMalloc((void **) &d_edges, edgesSize);
	cudaMalloc((void **) &d_depths, depthsSize);
	cudaMalloc((void **) &d_frontiers, frontiersSize);

	// copy from file to host memory
	int n = 0;
	int counter = 0;
	int edgeCounter = 0;
	int startVertex, endVertex;

	printf("Reading file ...\n");
	for (int i=0; i<nVertices; i++) {
		h_vertices[i] = edgeCounter;
		fscanf(fp, "%d", &n);

		for (int j=0; j<n; j++) {
			fscanf(fp, "%d", &startVertex);
			fscanf(fp, "%d", &endVertex);	
			h_edges[edgeCounter] = endVertex;
			edgeCounter++;
		}
	}
    fclose(fp);
	// Set the last vertice (which has index nVertices + 1) with the appropriate value. 
	// This vertice exists only for calculation purposes.
	h_vertices[nVertices] = edgeCounter;

	// init depths, frontiers and mask
	for (int i=0; i<nVertices; i++) {
		h_depths[i] = -1;
		h_frontiers[i] = 0;
	}

	// print check
	/*
	for (int i=0; i<nVertices+1; i++) {
		cout << h_vertices[i] << " ";
	}
	cout << "\n";

	for (int i=0; i<nEdges; i++) {
		cout << h_edges[i] << " ";
	}
	cout << "\n";
	*/

	// set the starting vertex as frontier
	h_frontiers[0] = 1; 
	// set the root vertex depth = 0
	h_depths[0] = 0;

	// init gpu arrays
	printf("Init device memory ...\n");
	cudaMemset(d_vertices, 0, verticesSize);
	cudaMemset(d_edges, 0, edgesSize);
	cudaMemset(d_depths, -1, depthsSize);
	cudaMemset(d_frontiers, 0, frontiersSize);

	// copy to gpu
	printf("Copy memory to device ...\n");
	cudaMemcpy(d_vertices, h_vertices, verticesSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_edges, h_edges, edgesSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_depths, h_depths, depthsSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_frontiers, h_frontiers, frontiersSize, cudaMemcpyHostToDevice);

	int h_hasChanges = 1;
	int nBlocks = nVertices / NUMBER_OF_THREADS_PER_BLOCK;
	if (nVertices % NUMBER_OF_THREADS_PER_BLOCK) {
		nBlocks++;
	}
	printf("\nNumber of blocks: %d\n", nBlocks);
	printf("Number of threads per blocks: %d\n", NUMBER_OF_THREADS_PER_BLOCK);
	printf("\nKernel launched\n");
	timer.Start();
	while (h_hasChanges) {
		// reset the flag to 'false' and copy the value to the device
		h_hasChanges = 0;
		cudaMemcpyToSymbol(d_hasChanges, &d_hasChanges, sizeof(int), 0, cudaMemcpyHostToDevice);

		// kernel
		bfs<<<nBlocks, NUMBER_OF_THREADS_PER_BLOCK>>>(d_vertices, d_edges, d_depths, d_frontiers, nVertices);

		// get the flag from the device
		cudaMemcpyFromSymbol(&h_hasChanges, d_hasChanges, sizeof(int), 0, cudaMemcpyDeviceToHost);
		//printf("MAIN LOOP FINISHED\n");
	}
	timer.Stop();
	
	cout << "Total time: " << timer.Elapsed() << "ms\n";

	// copy to host
	cudaMemcpy(h_depths, d_depths, depthsSize, cudaMemcpyDeviceToHost);

	// write to file
	fp1 = fopen("D:\\output.txt", "w+");
	for (int i=0; i<nVertices; i++) {
		fprintf(fp1, "%d:\t%d\n", i, h_depths[i]);
	}
	fclose(fp1);


	// print 
	/*
	for (int i=0; i<nVertices; i++) {
		cout << h_depths[i] << " ";
	}
	*/

	// wait
	scanf("%d", NULL);
    
	return 0;
}

