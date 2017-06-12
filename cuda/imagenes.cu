#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <iostream>
#include <cmath>
#include <string>

using namespace std;
#define CHANNELS 3
#define BLUR_SIZE 1

void print_vect(int *V, int n){
    int i;
    for (i = 0; i < n; i++)
		printf("%d ", V[i]);
}

int* ReadSizeImg(char * name)
{
    int * dim= new int[2];
    int fil, col;
    string line,s1;
    ifstream file(name);
    getline(file,line);
    getline(file,line);
    file>>fil>>col;
    dim[0]=fil; dim[1]=col;   
    return dim;
}
void ReadPPM(int *Pin, char *name)
{
	int e1;
    string line,s1;
    ifstream file(name);
    getline(file,line);
    getline(file,line);
    getline(file,line);
    getline(file,line);
    int m=0;
    while(!file.eof())
    {
        file>>e1;
       // cout<<e1<<endl;
        //if(!e1) break;
        Pin[m]=e1;
        m++;
    }
}

void WritePGM(int * Pout, int fil , int cols, char *name)
{
    ofstream file(name);
    file<<"P2"<<endl;
    file<<fil<<" "<<cols<<endl;
    file<<255<<endl;
    int n = fil*cols;
    int i=0;
    while(i<n)
    {
        file<<Pout[i]<<endl;
        i++;
    }
}

void WritePPM(int * Pout, int fil , int cols, char *name)
{
    ofstream file(name);
    file<<"P3"<<endl;
    file<<fil<<" "<<cols<<endl;
    file<<255<<endl;
    int n = fil*cols;
    int i=0;
    while(i<3*n)
    {
        file<<Pout[i]<<endl;
        i++;
    }
}


// we have 3 channels corresponding to RGB
// The input image is encoded as unsigned characters [0, 255]
__global__
void colorToGreyscaleConversion(int * Pout, int * Pin, int width, int height) 
{
	int Col = threadIdx.x + blockIdx.x * blockDim.x;
	int Row = threadIdx.y + blockIdx.y * blockDim.y;
	if (Col < width && Row < height) {
		// get 1D coordinate for the grayscale image
		int greyOffset = Row*width + Col;
		// one can think of the RGB image having
		// CHANNEL times columns than the grayscale image
		int rgbOffset = greyOffset*CHANNELS;
		int r = Pin[rgbOffset ]; // red value for pixel
		int g = Pin[rgbOffset + 2]; // green value for pixel
		int b = Pin[rgbOffset + 3]; // blue value for pixel
		// perform the rescaling and store it
		// We multiply by floating point constants
		Pout[greyOffset] = 0.21f*r + 0.71f*g + 0.07f*b;
	}
}

__global__
void blurKernel(int * in, int * out, int w, int h) 
{
	int Col = blockIdx.x * blockDim.x + threadIdx.x;
	int Row = blockIdx.y * blockDim.y + threadIdx.y;
	if (Col < w && Row < h) {
		int pixVal = 0;
		int pixels = 0;
		// Get the average of the surrounding 2xBLUR_SIZE x 2xBLUR_SIZE box
		for(int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1; ++blurRow) {
			for(int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1; ++blurCol) {
				int curRow = Row + blurRow;
				int curCol = Col + blurCol;
				// Verify we have a valid image pixel
				if(curRow > -1 && curRow < h && curCol > -1 && curCol < w) {
					pixVal += in[curRow * w + curCol];
					pixels++; // Keep track of number of pixels in the accumulated total
				}
			}
		}
		// Write our new pixel value out
		printf("Esperado %d  %d  %d \n",pixVal,pixels , pixVal / (float)pixels );
		out[Row * w + Col] = (int)(pixVal / (float)pixels);
	}
}

int main()
{
	int * Pin,* Pout;
    int * d_Pin,* d_Pout;
	int * order = ReadSizeImg("out2.ppm");
	int N=order[0]; int M=order[1];
	int THREADS_PER_BLOCK = 16
;    int size = 3*N*M*sizeof(int);

    cout<<"tamano Imagen "<<N<<" "<<M<<"  size "<<size<<endl;

    cudaMalloc((void **)&d_Pin, size);
	cudaMalloc((void **)&d_Pout, size);
    cout<<"pasa"<<endl;
    Pin = (int *)malloc(size); 		ReadPPM(Pin,"out2.ppm");
    //print_vect(Pin,3*order[0]*order[1]);
    Pout = (int *)malloc(size); 

	cudaMemcpy(d_Pin, Pin, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_Pout, Pout, size, cudaMemcpyHostToDevice);

	int blocks= (N + THREADS_PER_BLOCK -1)/THREADS_PER_BLOCK;
	dim3 dimGrid(blocks, blocks, 1);
	dim3 dimBlock(THREADS_PER_BLOCK,THREADS_PER_BLOCK, 1);
	cout<<"blocks : \n"<<blocks<<"\n threds: \n "<<THREADS_PER_BLOCK<<endl; 
		colorToGreyscaleConversion<<<dimGrid,dimBlock>>>( d_Pout, d_Pin, N, M);
		//blurKernel<<<dimGrid,dimBlock>>>( d_Pout, d_Pin, N, M);
	cudaMemcpy(Pout, d_Pout, size, cudaMemcpyDeviceToHost);
	WritePGM(Pout, N,M,"out22.ppm");  
	//WritePPM(Pout, N,M,"n.ppm");  
	free(Pin); free(Pout);
	cudaFree(d_Pin); cudaFree(d_Pout);
	return 0;
}