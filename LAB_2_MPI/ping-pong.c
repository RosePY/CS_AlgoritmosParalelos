#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char** argv) {
  const int n_operaciones = 10;


  MPI_Init(NULL, NULL);
  // Find out rank, size
  int rank_actual;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank_actual);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  int pp_contador = 0;
  int rank = (rank_actual + 1) % 2;
  while (pp_contador < n_operaciones) {
    if (rank_actual == pp_contador % 2) {
      pp_contador++;
      MPI_Send(&pp_contador, 1, MPI_INT, rank, 0, MPI_COMM_WORLD);
      sleep(1);//0.5 seg
      printf("Proceso %d envio e incremento pp_contador %d  al proceso %d\n",
             rank_actual, pp_contador, rank);
      sleep(1);//0.5 seg
    } else {
      MPI_Recv(&pp_contador, 1, MPI_INT, rank, 0, MPI_COMM_WORLD,
               MPI_STATUS_IGNORE);
      sleep(1);//0.5 seg
      printf("Proceso %d recibio pp_contador %d de proceso %d\n",
             rank_actual, pp_contador, rank);
      sleep(1);//0.5 seg
    }
  }
  MPI_Finalize();
}