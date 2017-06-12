
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <omp.h>
#include <time.h>
using namespace std; 
vector<float> fill(int count_num )
{
	vector<float> data;
	float maximo=7.0,minimo=3.0;
	for (int i=0;i<count_num;++i)
    {
           //float r= static_cast <float> (rand()) / (static_cast <float> (RAND_MAX/maximo));
           float r = minimo + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(maximo-minimo)));
           //cout<<"elemento: "<< i <<" contenido: " << r<<endl; 
           data.push_back(r);
    }
    return data;
}
vector<float>  Count_sort_serial (vector<float> lista, int n ) 
{
	int  count ;
	vector<float> temp ;
	for (int k=0;k<n;++k)
    {
            float e=0.0;
            temp.push_back(e);
    }
	for (int i = 0; i < n ; ++i) 
	{
		count = 0;
		for (int j = 0; j < n ; ++j)
		{
			if ( lista [j] < lista [i])
			{
				count ++;
			}
			else 
			{
				if ( lista [j] == lista [i] && j < i )
				{
					count ++;
				}
			}

		}
		temp [ count ] = lista [ i ];
    }

    return temp;
}
vector<float> Count_sort_parallel (vector<float> lista, int n , int nthreads) 
{
	int  count ;
	vector<float> temp ;
	omp_set_num_threads(nthreads);
	 #pragma omp parallel 
    {
       #pragma omp for schedule( auto )
       for (int i=0;i<n;++i)
        {
            float e=0.0;
            temp.push_back(e);
        }
       
    }
	
	for (int i = 0; i < n ; ++i) 
	{
		count = 0;
		#pragma omp parallel for private(i) shared(count, lista, n)
		for (int j = 0; j < n ; ++j)
		{
			if ( lista [j] < lista [i])
			{
				#pragma omp atomic
				count ++;
			}
			else 
			{
				if ( lista [j] == lista [i] && j < i )
				{
				    #pragma omp atomic
					count ++;
				}
			}

		}
		temp [ count ] = lista[ i ];
    }
    return temp;
    
}

int compvar(const void *one, const void *two)
{
    int a = *((int*)one);
    int b = *((int*)two);
    if (a<b)
       return -1;
    if (a == b)
       return 0;
    return 1;   

}

int main()
{
	vector<float> lista_nueva=fill(100000);
	double timeIni1, timeFin1,timeIni_par,timeFin_par;
    timeIni1 = omp_get_wtime();
    cout<<"\t-------------PROGRAMA EN FORMA SERIAL-------------"<<endl;
    //Count_sort_serial (lista_nueva, 100000);
    
    timeFin1 = omp_get_wtime();
    cout<<"Tiempo del programa serial = "<< timeFin1 - timeIni1 <<" segundos"<<endl;
    cout<<"\t-------------PROGRAMA EN FORMA PARALELA-------------"<<endl;
 
    timeIni_par = omp_get_wtime();
    //Count_sort_parallel(lista_nueva, 100000,10);
    timeFin_par = omp_get_wtime();
    cout<<"Tiempo del programa paralelo = "<< timeFin_par- timeIni_par<<" segundos"<<endl;
        cout<<"\t-------------PROGRAMA CON QSORT-------------"<<endl;
 
    timeIni_par = omp_get_wtime();
    //qsort (&lista_nueva[0], 100000, sizeof(float),compvar);
  
    timeFin_par = omp_get_wtime();
    cout<<"Tiempo del programa paralelo = "<< timeFin_par- timeIni_par<<" segundos"<<endl;


	 
}