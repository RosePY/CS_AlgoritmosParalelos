#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
using namespace std;
int thread_count;

double my_rand() 
{
   double numero = (double) random() / (double) RAND_MAX;
   if((double) random() / (double) RAND_MAX < 0.5) numero *= -1;
   return numero;
}

double smonte_carlo(long long number_tosses)
{
   long long number_in_circle, i;
   double x, y, distancie_squared;

   number_in_circle =0;
   srandom(0);

   for (i = 0; i < number_tosses; i++) 
   {
      x = my_rand();
      y = my_rand();
      distancie_squared = x*x + y*y;

      if (distancie_squared <= 1) number_in_circle ++;
   }

   double pi = 4*number_in_circle/((double) number_tosses);
   return pi;
   
}

double pmonte_carlo(long long number_tosses)
{
   long long number_in_circle, i;
   double x, y, distancie_squared;

   number_in_circle =0;
   srandom(0);
#  pragma omp parallel for num_threads(thread_count) \
      reduction(+: number_in_circle) shared(number_tosses) private(x, y, distancie_squared)
   for (i = 0; i < number_tosses; i++) 
   {
      x = my_rand();
      y = my_rand();
      distancie_squared = x*x + y*y;

      if (distancie_squared <= 1) number_in_circle ++;
   }

   double pi = 4*number_in_circle/((double) number_tosses);
   return pi;
   
}
int main() 
{
      thread_count=100;
   float pi_original=3.14159;
   double pi;
   long long number_tosses1=pow(10,6);

   long long number_tosses2=pow(10,6);

    pi = smonte_carlo(number_tosses1);

    cout<<"PI calculado: "<<pi<<"\t PI real: "<<pi_original<<"\t error: "<<pi_original-pi<<endl;
    
    
}