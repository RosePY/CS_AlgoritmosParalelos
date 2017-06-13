#include <assert.h>
#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>



const int N = 16384;
const int THREADS_PER_BLOCK = 512;



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

  a = (int *) malloc(size);
  b = (int *) malloc(size);
  c = (int *) malloc(size);


  for (int i = 0; i < N; ++i) {
    a[i] = rand();
    b[i] = rand();
  }
  //uint kernelTime;
  //cutCreateTimer(&kernelTime);
  //cutResetTimer(kernelTime);
  cudaMalloc((void **) &d_a, size);
  cudaMalloc((void **) &d_b, size);
  cudaMalloc((void **) &d_c, size);
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
  //cutStartTimer(kernelTime);
  add_threads_blocks<<<(N + (THREADS_PER_BLOCK - 1)) / THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(d_a, d_b, d_c, N);
  // cudaThreadSynchronize();
  //cutStopTimer(kernelTime);
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
  printf("Suma con  %d hebras con %d hebras por bloque!\n", N, THREADS_PER_BLOCK);
  //printf ("Time for the kernel: %f ms\n", cutGetTimerValue(kernelTime));
  free(a); free(b); free(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

  return 0;
}






