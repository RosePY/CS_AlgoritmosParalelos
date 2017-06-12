#include <assert.h>
#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

/* Example from "Introduction to CUDA C" from NVIDIA website:
   https://developer.nvidia.com/cuda-education
   
   Compile with:
   $ nvcc example_intro.cu */

const int N = 16384;
const int THREADS_PER_BLOCK = 512;

/* Running one thread in each block (slides 24-32) */
__global__ void add_blocks (int *a, int *b, int *c) {
  /* blockIdx.x gives each block ID */
  c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

/* Running multiple threads in one block (slides 33-36) */
__global__ void add_threads (int *a, int *b, int *c) {
  /* threadIdx.x gives the thread ID in each block */
  c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x];
}

/* Running multiple threads in multiple blocks (slides 37-45).
   While doing this seems unecessary, in some cases we need threads
   since they have communication (__shared__ variables) and
   synchronization (__syncthreads()) mechanisms,
 */
__global__ void add_threads_blocks (int *a, int *b, int *c, int n) {
  /* blockDim.x gives the number of threads per block, combining it
     with threadIdx.x and blockIdx.x gives the index of each global
     thread in the device */
  int index = threadIdx.x * blockIdx.x * threadIdx.x;
  /* Typical problems are not friendly multiples of blockDim.x.
     Avoid accesing data beyond the end of the arrays */
  if (index < n) {
    c[index] = a[index] + b[index];
  }
}

int main(void) {
  int *a, *b, *c; /* Host (CPU) copies of a, b, c */
  int *d_a, *d_b, *d_c; /* Device (GPU) copies of a, b, c */
  size_t size = N * sizeof(int);

  srand(1);

  /* Allocate memory in device */
  cudaMalloc((void **) &d_a, size);
  cudaMalloc((void **) &d_b, size);
  cudaMalloc((void **) &d_c, size);

  /* Allocate memory in host */
  a = (int *) malloc(size);
  b = (int *) malloc(size);
  c = (int *) malloc(size);

  /* Allocate random data in vectors a and b (inside host) */
  for (int i = 0; i < N; ++i) {
    a[i] = rand();
    b[i] = rand();
  }

  /* Copy data to device */
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);


  /* Launch add() kernel on device with N threads in N blocks */
  add_threads_blocks<<<(N + (THREADS_PER_BLOCK - 1)) / THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(d_a, d_b, d_c, N);
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  /* Check if everything is alright */

  printf("Suma con  %d hebras!\n", N);

  /* Clean-up */
  free(a); free(b); free(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

  return 0;
}

/*
  /* Launch add() kernel on device with N blocks *
  add_blocks<<<N,1>>>(d_a, d_b, d_c);
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

 /* /* Check if everything is alright *
  for (int i = 0; i < N; ++i) {
    assert(c[i] == a[i] + b[i]);
  }
  printf("Version with %d blocks executed succesfully!\n", N);

  /* Launch add() kernel on device with N threads *
  add_threads<<<1,N>>>(d_a, d_b, d_c);
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  /* Check if everything is alright *
  for (int i = 0; i < N; ++i) {
    assert(c[i] == a[i] + b[i]);
  }*
  printf("Suma con  %d hebras!\n", N);
  */