#include <iostream>
#include <vector>
#include "omp.h"    

using namespace std;


int find_pos(vector<float> pos, float num)
{
   for (int i=0;i<pos.size();++i)
   {
      if(num <= pos[i])
      {
        return i;
      }
   }
}

int get_pos(float data , vector<float> bin_maxes, int nbins) 
{
   int actual = 0, tope =  nbins-1;
   int pos;
   float bin_max, bin_min;

   while (actual <= tope) 
   {
      pos = (actual + tope)/2;
      bin_max = bin_maxes[pos+1];
      bin_min= bin_maxes[pos];
      if (data >= bin_max) 
         actual = pos+1;
      else if (data < bin_min)
         tope = pos;
      else  
         return pos;

      if(pos==4 && data==bin_max)
        return pos;
   }
}

vector<int> parallel_histogram(vector<float> datos,float nbins){
  float max=0;
  float min=datos[0];
  #pragma omp parallel 
  {
    #pragma omp for
      for(int i=0;i<datos.size();++i){
        #pragma omp critical
          if(max<datos[i]) max=datos[i];
          else if(min>datos[i]) min = datos[i];
      }
  }
  //cout<< max << " " << min << endl;
  vector<int> bin_cont;
  vector<float> bin_max;

  bin_max.resize(nbins+1);
  bin_cont.resize(nbins);
  bin_max[0]=min;
  float bin_width=(max-min)/nbins;
  for(int i=0;i<nbins;i++)
  {
    bin_max[i+1]=min+bin_width*(i+1);
  }

  int i=0,pos=0;
  #pragma omp parallel 
  {
    #pragma omp for 
    for (i = 0; i <datos.size(); i++) {
      pos = get_pos(datos[i], bin_max, nbins);
      #pragma omp critical
      bin_cont[pos]++;
    }
  }
  #pragma opm parallel
  {

    #pragma omp for
      for(int i=0;i<bin_cont.size();++i){
        cout<<"Números en intervalo "<<bin_max[i]<<" - "<<bin_max[i+1]  << " : " << bin_cont[i]<<'\n';
      }
  }
  return bin_cont;
}

vector<int> serial_histogram(vector<float> datos,float nbins){
  float max=0;
  float min=datos[0];

      for(int i=0;i<datos.size();++i){
          if(max<datos[i]) max=datos[i];
          else if(min>datos[i]) min = datos[i];
      }
  
  //cout<< max << " " << min << endl;
  vector<int> bin_cont;
  vector<float> bin_max;

  bin_max.resize(nbins+1);
  bin_cont.resize(nbins);
  bin_max[0]=min;
  float bin_width=(max-min)/nbins;
  for(int i=0;i<nbins;i++)
  {
    bin_max[i+1]=min+bin_width*(i+1);
  }

  int i=0,pos=0;
  
     for (i = 0; i <datos.size(); i++) {
      pos = get_pos(datos[i], bin_max, nbins);
       bin_cont[pos]++;
    }
  
  for(int i=0;i<bin_cont.size();++i){
        //cout<<"Números en intervalo "<<bin_max[i]<<" - "<<bin_max[i+1]  << " : " << bin_cont[i]<<'\n';
      }
  
  return bin_cont;
}


int main() {

  vector<float> datos { 1.3, 2.9, 0.4, 0.3, 1.3, 4.4, 1.7, 0.4, 3.2, 0.3, 4.9, 2.4, 3.1, 4.4, 3.9, 0.4, 4.2, 4.5, 4.9, 0.9 };
  std::vector<float> datax;
  float nbins1=5, nbins2=12;
  int nn=1000000;
  for (int i=0;i<nn;++i)
    {
        float r = static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(25000)));
        datax.push_back(r);
    }
  //cout<<"-------------PROGRAMA EJEMPLO LIBRO-------------"<<endl;
  //parallel_histogram(datos,nbins1);
  cout<<"-------------PROGRAMA CON 1 000 000 DATOS-------------"<<endl;  
  double top0 = omp_get_wtime();  
  parallel_histogram(datax,nbins2);
  double tfp0 = omp_get_wtime();
  cout<<"Tiempo del programa paralelo = "<< tfp0-top0<<" segundos"<<endl;

  return 0;
}
