#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )

typedef int NUM;

struct Matrix
{
	int r, c;
	NUM **m;
};

void print(struct Matrix m) {
	int i, j;
	for (i = 0; i < m.r; ++i) {
		for (j = 0; j < m.c; ++j) 
		  	printf("%d\t", m.m[i][j]);
		printf("\n");
	}
}

void generate(struct Matrix *m) {
	int i, j;
	m->m = malloc(m->r * sizeof(NUM*));
	for (i = 0; i < m->r; ++i) {
		m->m[i] = malloc(m->c * sizeof(NUM));
		for (j = 0; j < m->c; ++j)
		  	m->m[i][j] = (rand() % 10);
	}
}

struct Matrix bloqued_version(struct Matrix a, struct Matrix b, int blocks) {
	struct Matrix m;
	m.r = a.r; m.c = b.c;
	int i, j, k, ii, jj, kk;
	m.m = malloc(m.r * sizeof(NUM*));
	for(i = 0; i < m.r; i++){
		m.m[i] = malloc(sizeof(NUM) * m.c);
	}
	for(i = 0; i < m.r; i++){
		for(j = 0; j < m.c; j++){
			m.m[i][j] = 0;
		}
	}
	for(ii = 0; ii < m.r; ii += blocks) {
		for(jj = 0; jj < m.c; jj +=  blocks) {
			for(kk = 0; kk < a.c; kk += blocks) {
				for(i = ii; i < min(ii + blocks, m.r); ++i) {
					for(j = jj; j < min(jj + blocks, m.c); ++j) {
						for(k = kk; k < min(kk + blocks, a.r); ++k)
							m.m[i][j] = m.m[i][j] + (a.m[i][k] * b.m[k][j]);
					}
				}
			}
		}
	}
	return m;
}

int main(int argc, char *argv[])
{
	srand(time(NULL));

	int n = 1500, blk = 10;
	struct Matrix m1, m2, p1, p2;
	m1.r = n; m1.c = n; m2.r = n; m2.c = n;

	generate(&m1);
	generate(&m2);

	/*print(m1);
	printf("\n");
	print(m2);
	printf("\n");*/

	clock_t start = clock(), end;
	p2 = bloqued_version(m1, m2, n / blk);
	end = clock();
	printf("%f\n", ((double)	(end - start) / CLOCKS_PER_SEC));
	//print(p2);

	return 0;
}
