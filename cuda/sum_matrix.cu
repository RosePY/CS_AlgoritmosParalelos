#include <assert.h>
#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>



const int N = 16384;
const int THREADS_PER_BLOCK = 512;


__global__ void add_blocks (int *a, int *b, int *c) {

  c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}


__global__ void add_threads (int *a, int *b, int *c) {

  c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x];
}

__global__ void add_threads_blocks (int *a, int *b, int *c, int n) {

  int index = threadIdx.x * blockIdx.x * threadIdx.x;
  if (index < n) {
    c[index] = a[index] + b[index];
  }
}

int main(void) {
  int *a, *b, *c; 
  int *d_a, *d_b, *d_c; 
  size_t size = N * sizeof(int);

  srand(1);


  cudaMalloc((void **) &d_a, size);
  cudaMalloc((void **) &d_b, size);
  cudaMalloc((void **) &d_c, size);


  a = (int *) malloc(size);
  b = (int *) malloc(size);
  c = (int *) malloc(size);


  for (int i = 0; i < N; ++i) {
    a[i] = rand();
    b[i] = rand();
  }


  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);


  add_threads_blocks<<<(N + (THREADS_PER_BLOCK - 1)) / THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(d_a, d_b, d_c, N);
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    printf("Suma con  %d hebras!\n", N);

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