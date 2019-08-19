#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include "Signal.h"
#include "LinkedList.h"
#include "predictDigit.h"
#include "splitSequence.h"

DigitSequence bestSplit(Signal* signal, Database* database, size_t locality, size_t lMin, size_t lMax)
{
    printf("n_coef : %u \n", signal->size);

    DigitSequence split;// création de la variable renvoyée
    DigitSequence error;// création de la variable à renvoyer en cas d'erreur

    DigitScore digitScore;// Le score du digit détecté

    //initialisation
    error.score=-1;
    error.nDigits=-1;
    error.digits=NULL;
    error.splits=NULL;

	DigitSequence* memoization=malloc((signal->size+1) * sizeof(DigitSequence));
	split.score=0;
	split.nDigits=0;
	split.digits=NULL;
    split.splits=NULL;

	memoization[0]=split;
	double score;

	for(size_t length=1; length<=signal->size; length++)
	{
	    printf(" length = %u : ", length);
		score=DBL_MAX;
		for(size_t k=lMin; k<=lMax && k<=length; k++)
		{
			/*-------------------------------------------------Découpe-----------------------------*/

			Signal* digit=malloc(sizeof(Signal));
			// -----------------------
			if(!digit)
			{
				free(digit);
				free(memoization);
				return error;
			}
			// ------------------------

			//on recopie le nombre de coefficient
			digit->n_coef=signal->n_coef;

			//on définit la taille du signal
			digit->size=k;

			//on déclare le tableau "mfcc"
			digit->mfcc = malloc(digit->n_coef * sizeof(double*));
			// ------------------------
			if (!digit->mfcc) {
				free(digit);
				free(memoization);
				return error;
			}
			for (size_t i = 0; i < digit->n_coef; i++) {
				digit->mfcc[i] = malloc(digit->size * sizeof(double));
				if (!digit->mfcc[i]) {
					// deallocate previously allocated arrays
					for(size_t j = i - 1; j < i; --j) {
						free(digit->mfcc[j]);
					}
					free(digit->mfcc);
					free(digit);
					free(memoization);
					return error;
				}
			}
			//on recopie les valeurs du signal dans les deux "sous-signaux"
			for(size_t i=0;i<signal->n_coef;i++)
			{
				for(size_t j=0; j<k;j++)
				{
					digit->mfcc[i][j]=signal->mfcc[i][length-k+j];
				}
			}
			/*---------------------------------------------Fin Découpe-----------------------------*/

			//détection d'un digit dans le signal (k)
			digitScore=predictDigit(digit,database,locality);

			// On a plus besoin de digit à partir d'ici

            // --------------------------
            // if q < p[i] + r[j-i]
            //     q =p[i] + r[j-i]
            double tmp=score;
			score=fmin(score,digitScore.score+memoization[length-k].score); //lMax, length

			if(score!=tmp)
            {
                split.score=score;
            // ---------------------------
                split.nDigits++;

                //champ digits : ajout d'une case au tableau, shift et ajout d'une valeur
                split.digits=realloc(split.digits, split.nDigits * sizeof(int));

                // En cas d'erreur d'allocation
                if(!split.digits)
                {
                    free(split.digits);
                    for(size_t i = 0; i < digit->n_coef; i++) {
                        free(digit->mfcc[i]);
                    }
                    free(digit->mfcc);
                    free(digit);
                    free(memoization);
                    return error;
                }

                //on shift les champs
                for(size_t i=split.nDigits-1;i>0;i--)
                {
                    split.digits[i]=split.digits[i-1];
                }
                split.digits[0]=digitScore.digit; //on rajoute la valeur courante

                //champ splits : ajout d'une case au tableau, shift et ajout d'une valeur
                split.splits=realloc(split.splits, split.nDigits * sizeof(int));
                if(!split.splits)
                {
                    free(split.splits);
                    free(split.digits);
                    for(size_t i = 0; i < digit->n_coef; i++) {
                        free(digit->mfcc[i]);
                    }
                    free(digit->mfcc);
                    free(digit);
                    free(memoization);
                    return error;
                }
                for(size_t i=split.nDigits-1;i>0;i--) //on shift les champs
                {
                    split.splits[i]=split.splits[i-1]+k;
                }
                split.splits[0]=0; //on rajoute la valeur courante
            }

            for (size_t i = 0; i < digit->n_coef; i++) {
				free(digit->mfcc[i]);
            }
            free(digit->mfcc);
            free(digit);

		} // end for k
		memoization[length]=split;
		printf("Score : %d \n" , split.score );

	} // end for length
	free(split.digits);
	free(split.splits);

    DigitSequence sequenceDetected = memoization[signal->size+1];
    free(memoization);

    return sequenceDetected;
}
