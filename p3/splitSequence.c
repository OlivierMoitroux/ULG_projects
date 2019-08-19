#include <float.h>
#include <stdint.h>
#include <stdio.h>
#include "Signal.h"
#include "LinkedList.h"
#include "predictDigit.h"
#include "splitSequence.h"

DigitSequence bestSplit(Signal* signal, Database* database, size_t locality, size_t lMin, size_t lMax)
{
    DigitSequence *memoization;
    DigitScore scoreCut;

    DigitSequence error;
    error.score=0;
    error.nDigits=0;
    error.digits=NULL;
    error.splits=NULL;

    memoization=malloc(((signal->size/lMin)+1) * sizeof(DigitSequence));
    if(!memoization)
    {
        return error;
    }
    memoization[0]=error;

    size_t* splits=malloc(signal->size * sizeof(size_t));

    for(size_t j=1; j<=(signal->size/lMin); j++)
    {
        double score=DBL_MAX;
        for(size_t i=lMin;(i<=j && i<=lMax); i++)
        {
            size_t a=i-lMin+1;
            /*---------------------Découpe du signal---------------------------*/
            Signal* cut=malloc(sizeof(Signal));
            if(!cut)
            {
                free(memoization);
                return error;
            }

            cut->n_coef=signal->n_coef;
            cut->size=i;

            cut->mfcc=malloc(cut->n_coef * sizeof(double*));
            if(!cut->mfcc)
            {
                free(cut);
                free(memoization);
                return error;
            }
            for(size_t k=0;k<cut->n_coef;k++)
            {
                cut->mfcc[k]=malloc(cut->size * sizeof(double));
                if(!cut->mfcc[k])
                {
                    for(size_t l=k-1;l<k;l--)
                    {
                        free(cut->mfcc[l]);
                    }
                    free(cut->mfcc);
                    free(cut);
                    free(memoization);
                    return error;
                }
            }

            for(size_t k=0;k<cut->n_coef;k++)
            {
                for(size_t l=0;l<cut->size;l++)
                {
                    cut->mfcc[k][l]=signal->mfcc[k][j-i+l]; // l ou j - a
                }
            }
            /*-----------Fin de la découpe du signal---------------------------*/

            scoreCut=predictDigit(cut,database,locality);

            if(score>(scoreCut.score+memoization[j-a].score))
            {
                score=(scoreCut.score+memoization[j-a].score);
                size_t b=j-lMin+1;
                splits[b-1]=a;
            }

            for(size_t k=0;k<cut->n_coef;k++)
            {
                free(cut->mfcc[k]);
            }
            free(cut->mfcc);
            free(cut);


        }
        if(lMin<=j)
        {
            size_t b=j-lMin+1;
            memoization[b].score=score;
            memoization[b].nDigits=memoization[b-(splits[b-1])].nDigits+1;

            memoization[b].digits=malloc(memoization[b].nDigits * sizeof(int));
            memoization[b].digits[0]=scoreCut.digit;
            for(size_t k=1;k<memoization[b].nDigits;k++)
            {
                memoization[b].digits[k]=memoization[b-(splits[b-1])].digits[k-1];
            }

            memoization[b].splits=malloc(memoization[b].nDigits * sizeof(size_t));
            memoization[b].splits[0]=0;
            for(size_t k=1;k<memoization[b].nDigits;k++)
            {
                memoization[b].splits[k]=(memoization[b-(splits[b-1])].splits[k-1]+splits[b-1]);
            }

            printf("Iteration %u mais indice %u : Score = %f\n", j, b, score);
        }
    }

    return memoization[signal->size/lMin-lMin+1];
}
