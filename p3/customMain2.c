
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <stdio.h>

#include "predictDigit.h"
#include "Signal.h"
#include "LinkedList.h"

/* ------------------------------------------------------------------------- *
 * This program attempts to recognize a digit.
 *
 * PARAMETERS
 * mfcc_file        The file containing the mfcc transform of the digit
 * database_dir     The path to the directory containing the reference samples
 * locality         The locality constraint (unsigned int) [OPTIONAL]
 * ------------------------------------------------------------------------- */
int main(int argc, char** argv) {

    if (argc != 3 && argc != 4) {
        fprintf(stderr, "USAGE: %s <mfcc_file> <database_dir> [<locality>]\n",
                argv[0]);
        return EXIT_FAILURE;
    }

    Database* sampleBase = parseDatabase(argv[1]);
    if (!sampleBase) {
        fprintf(stderr, "Cannot load the sampleBase from directory '%s'... Exit!\n", argv[1]);
        return EXIT_FAILURE;
    }

    Database* database = parseDatabase(argv[2]);
    if (!database) {
        fprintf(stderr, "Cannot load the database from directory '%s'... Exit!\n", argv[2]);
        return EXIT_FAILURE;
    }

    size_t locality = SIZE_MAX;
    if (argc == 4)
    {
        if(sscanf(argv[3], "%u", &locality) != 1)
        {
            fprintf(stderr, "Cannot parse the locality '%s'... Exit!\n", argv[3]);
            return EXIT_FAILURE;
        }
    }

    LLNode* curr;

    // Signal* unknownSignal;

    printf("Computing...\n");
    for(locality = SIZE_MAX ; locality > 1 ; locality /= 10){
        for(size_t i = 0 ; i < 10 ; i++ ){
            curr = sampleBase->samples[i]->head;
            for(size_t j = 0 ; j < database->samples[i]->size; j++){



                /* unknownSignal = parseSignal(curr);
                if (!unknownSignal) {
                    fprintf(stderr, "Cannot load the signal from file '%s'... Exit!\n", argv[1]);
                    return EXIT_FAILURE;
                }
                */

                DigitScore digtScore = predictDigit((Signal*) curr->value, database, locality);

                if(digtScore.digit != (int)i){
                    printf("FAILED !!! \n");
                    printf("Detected = '%d' , Attendu : %u, Intonnation :  %u .mfcc \n", digtScore.digit, i, j+6);
                    printf("Score = %lf\n", digtScore.score);
                    printf("Locality = %u", locality);
                }



                curr = curr->next;

            }
        }


    }
    //freeSignal(unknownSignal);
    freeDatabase(sampleBase);
    freeDatabase(database);
    return EXIT_SUCCESS;
}
