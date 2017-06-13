#include <iostream>
#include <fstream>
#include <string>
#include "CImg.h"
#include <vector>

using namespace cimg_library;
using namespace std;

//def N 5;
//map<float,float*>  red;


int main()
{


   string it="lena.jpg";

   ofstream fil("lena.dat");

   /*Escritura de archivo de entrada*/
      CImg<float>   A((char*)it.c_str());
      A.display(); 
/*
      cimg_forXY(A,x,y)
      {
         float r = A(x, y,  0);
         float g = A(x, y, 1);
         float b = A(x, y, 2);
         fil<<r<<" "<<g<<" "<<b<<endl;
      }
*/
   
   /*Muestra de archivo de salida*/
   CImg<float> B(A);
   CImg<float> gray(B.width(), B.height(), 1, 1, 0);
   B.fill(0);
   //B.display();
  /* int i=0;
   int j=0,z=0;
   float a,b,c;
   ifstream arch("gray.dat");
   while(!arch.eof())
   {
      arch>>a;
      gray(j,i)=a;
      j++;
      if(j%225==0){
         j=0;
         i++;
      } 
   }
   gray.display();
   return 1;

   /*/
   int i=0;
   int j=0,z=0;
   float a,b,c;
   ifstream arch("bluur.dat");
   while(!arch.eof())
   {
      arch>>a>>b>>c;
      B(j,i,0)=a;
      B(j,i,1)=b;
      B(j,i,2)=c;
      j++;
      if(j%225==0){
         j=0;
         i++;
      } 
   }
   B.display();
   return 1;//*/
}
