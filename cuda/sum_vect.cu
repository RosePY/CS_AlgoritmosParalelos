#include <iostream>
#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <string>
#include <cuda_runtime.h>
#include <cuda.h>
using namespace std;
__global__ void suma_vectores(float *c ,float *a , float *b,int N)
{
   int idx=blockIdx.x * blockDim.x+ threadIdx.x;
   if(idx<N)
   {
         c[idx]=a[idx] + b[idx];
   }
}
int main(void)
{
   float *a_h,*b_h,*c_h;
   float *a_d,*b_d,*c_d;
   int N=1000000;
   size_t size=N*sizeof(float);
   a_h = (float *) malloc (size);
   b_h = (float *) malloc (size);
   c_h = (float *) malloc (size);
   for (int i=0;i<N;i++)
   {
       a_h[i]=(float)i;
       b_h[i]=(float)(i+1);
   }
   cudaMalloc((void**)& a_d,size);
   cudaMalloc((void**)& b_d,size);
   cudaMalloc((void**)& c_d,size);

   cudaMemcpy(a_d,a_h,size,cudaMemcpyHostToDevice);
   cudaMemcpy(b_d,a_h,size,cudaMemcpyHostToDevice);
   int block_size=8;
   int n_blocks=N/block_size + (N%block_size ==0 ? 0:1);
   suma_vectores <<< n_blocks,block_size >>> (c_d,a_d,b_d,N);
   cudaMemcpy (c_h,c_d,size,cudaMemcpyDeviceToHost);
   /*for (int i=0;i<N;i++)
   {
      cout<<c_h[i]<<" "<<endl;
   }*/

   free(a_h);
   free(b_h);
   free(c_h);
   return(0);


}