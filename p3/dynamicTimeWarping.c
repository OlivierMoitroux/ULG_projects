/* ------------------------------------------------------------------------- *
* Implémentation de dtw
* ------------------------------------------------------------------------- */
#include <float.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <math.h>
#include "dynamicTimeWarping.h"

// signal1 = la sequence en test
// signal2 = la sequence de reference

/* ------------------------------------------------------------------------- *
* Calcule la distance absolue moyenne de deux points
* @Param :  double a, double b, double nCoef
* ------------------------------------------------------------------------- */
static double dist(double** a, double** b, size_t nCoef, size_t i, size_t j)
{
    double sum = 0 ;

    for(size_t h = 0; h < nCoef ; h++)
        sum += abs( a[h][i-1] - b[h][j-1] );

    return (sum/nCoef);
}

/* ------------------------------------------------------------------------- *
* Calcule le minimum de 3 éléments de type double
* @Param : double a, double b, double c
* ------------------------------------------------------------------------- */
static double min3(double a, double b, double c)
{
   double min = fmin(a, fmin(b,c));

   return (min);
}

/* ------------------------------------------------------------------------- *
* Renvoit l'élément max de deux size_t
* @Param : size_t a, size_t b
* ------------------------------------------------------------------------- */
static size_t max(size_t a, size_t b)
{
    return (a>b)?a:b;
}

/* ------------------------------------------------------------------------- *
* Renvoit l'élément min de deux size_t
* @Param : size_t a, size_t b
* ------------------------------------------------------------------------- */
static size_t min(size_t a, size_t b)
{
    return (a<b)?a:b;
}

static size_t plus(size_t a, size_t b)
{
    if(a==SIZE_MAX || b==SIZE_MAX || (a+b)<a || (a+b)<b)
        return SIZE_MAX;
    return a+b;
}

static size_t minus(size_t a, size_t b)
{
    if(b==SIZE_MAX || (a-b)>b)
        return 0;
    return a-b;
}

/* ------------------------------------------------------------------------- *
* calcule la distance dtw de deux signaux. cfr dynamicTimeWarping.h
* @Param : 2 signaux (signal1-signal2), locality
* ------------------------------------------------------------------------- */
double dtw(Signal* signal1, Signal* signal2, size_t locality)
{

	const size_t size1 = signal1->size;
	const size_t size2 = signal2->size;


	double** dtw = malloc((size1+1) * sizeof(double*));
	double cost;

	if (dtw == NULL)
		return DBL_MAX;

	for (size_t i = 0; i <= size1; i++) {
			dtw[i] = malloc((size2+1) * sizeof(double));
			if(dtw[i]==NULL) {
                // deallocate previously allocated arrays
                for(size_t j = i - 1; j < i; --j) {
                    free(dtw[j]);
                }
                free(dtw);
                return DBL_MAX;
			}
	}

	// contraintes locales (w) a adapter :
	locality = max(locality, abs(size1 - size2));

	for (size_t i = 0; i <= size1; i++) {
		for(size_t j=0 ; j<= size2;j++)
			dtw[i][j] = DBL_MAX;
	}
	dtw[0][0] = 0;

	for (size_t i = 1; i <= size1; i++)
    {
		for (size_t j = max(1, minus(i,locality)); j <= min(size2, plus(i,locality)); j++)
		{
			cost = dist(signal1->mfcc, signal2->mfcc, signal1->n_coef,i,j);
			dtw[i][j] = cost+min3(dtw[i-1][j], dtw[i][j-1], dtw[i-1][j-1]);
                                //insertion  - suppression- match
		}
	}

	double result = dtw[size1][size2];

	for (size_t i = 0; i <= size1; i++) {
		if(dtw[i] != NULL)
			free(dtw[i]);
	}
	if(dtw != NULL)
		free(dtw);

	return result;
}
