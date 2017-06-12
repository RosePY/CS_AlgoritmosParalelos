#include <stdio.h>
#include <fstream>
#include <iostream>
#define CHANNELS 3 // we have 3 channels corresponding to RGB
using namespace std;

#define CHANNELS 3 // we have 3 channels corresponding to RGB
// The input image is encoded as unsigned characters [0, 255]
__global__ void colorConvert(float * Pout, float * Pin, int width, int height)
{
  int Col = threadIdx.x + blockIdx.x * blockDim.x;
  int Row = threadIdx.y + blockIdx.y * blockDim.y;
  if (Col < width && Row < height)
  {
    // get 1D coordinate for the grayscale image
    int greyOffset = Row*width + Col;
    // one can think of the RGB image having
    // CHANNEL times columns than the grayscale image
    int rgbOffset = greyOffset*CHANNELS;
    float r = Pin[rgbOffset]; // red value for pixel
    float g = Pin[rgbOffset + 1]; // green value for pixel
    float b = Pin[rgbOffset + 2]; // blue value for pixel
    // perform the rescaling and store it
    // We multiply by floating point constants
    Pout[greyOffset] = 0.21f*r + 0.71f*g + 0.07f*b;
  }
}


void save_data(float o[225][225])
{
  ofstream archivo("gray.dat");
  for (int i = 0; i < 225; ++i)
  {
    for (int j = 0; j < 225; ++j)
    {
          archivo<<o[i][j]<<" ";
    }
    archivo<<endl;
  }
}

void GrayScale(float m[225][225*3],int width, int height)
{
  float o[225][225];

  int size_in = width * (height*3);
  int size_out = width * height;
  int memSize_in = size_in * sizeof(float);
  int memSize_out = size_out * sizeof(float);

  float *d_A, *d_B;

  cudaMalloc((void **) &d_A, memSize_in);
  cudaMalloc((void **) &d_B, memSize_out);

  cudaMemcpy(d_A, m, memSize_in, cudaMemcpyHostToDevice);

  dim3 DimGrid(floor((width-1)/16 + 1), floor((height-1)/16+1), 1);
  dim3 DimBlock(16, 16, 1);
  colorConvert<<<DimGrid,DimBlock>>>(d_B, d_A, width, height);
 
  cudaMemcpy(o, d_B, memSize_out, cudaMemcpyDeviceToHost);

  cudaFree(d_A);
  cudaFree(d_B);
  save_data(o);
}

void leer_data(const char *file, float m[225][225*3])
{
  char buffer[100];
  ifstream archivo2("image.dat");
  for (int ii = 0; ii < 225; ++ii)
  {
    for (int jj = 0; jj < 225; ++jj)
    {
          archivo2>>m[ii][jj*3]>>m[ii][jj*3+1]>>m[ii][jj*3+2];
    }
    archivo2.getline(buffer,100);
  }
}

int main()
{
  int width=225, height=225;
  float m[225][225*3];
  leer_data("image.dat",m);
  GrayScale(m,width,height);

  return EXIT_SUCCESS;
}