
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <float.h>
#include <limits.h>

#include "predictDigit.h"
#include "Signal.h"

int main() {
    char samplePath[80];
    char sampleName[80];

    char DBPath[80];
    // char DBName[80];

    size_t bestLocality;
    int nbreFailed ;
    int leastFailed = INT_MAX;


    for(size_t locality = SIZE_MAX; locality >= 1 ; locality /= 100){
        nbreFailed = 0;
        for (int sampleNumAnalyzed = 48; sampleNumAnalyzed <= 57 ; sampleNumAnalyzed++){ // de 0 à 9
                for(int sampleFileName = 54 ; sampleFileName <= 57; sampleFileName++){ // code ascii 6->9 et '1', '0' pour le cas 58

                    // SAMPLE
                    char* nbreFolder[1];
                    nbreFolder[0] = (char)sampleNumAnalyzed;

                    // printf("nbre folder initialized : %s \n \n", nbreFolder);

                    char nbreSample[2]; // car existe \0
                    if(sampleFileName == 58){
                        // 10 en ascii
                        nbreSample[0] = (char)49; //'1'
                        strcat(nbreSample, "0");
                        //nbreSample[1] = (char)48; //'0'
                        //nbreSample[2] = '\0'; // si enlevé ok nbreFolder mais 100 ici sinon nbreFolder existe plus
                        printf("\n %s \n", nbreSample);
                    }
                    else{
                        nbreSample[0] = (char)sampleFileName;
                    }

                    // printf("%s \n", nbreFolder);
                    // printf("%s", nbreSample);

                    strcpy(samplePath, "..\\..\\fourni\\p3_testDB\\testDB\\");
                    // printf("Sample path without nbreFolder : %s \n", samplePath);

                    strcat(samplePath, nbreFolder);
                    // printf("Sample path with nbreFolder : %s \n", samplePath);

                    strcpy(sampleName, "\\pg" );
                    strcat(sampleName, nbreSample);
                    strcat(sampleName, ".mfcc");


                    strcat(samplePath, sampleName);

                    // printf("SamplePath = %s \n", samplePath);

                    //DATABASE
                    strcpy(DBPath, "..\\..\\fourni\\p3_refDB\\refDB");

                    // printf("DBPath = %s \n", DBPath);


                    Signal* unknownSignal = parseSignal(samplePath);
                    if (!unknownSignal) {
                        fprintf(stderr, "Cannot load the signal from file '%s'... Exit!\n", samplePath);
                        return EXIT_FAILURE;
                    }

                    Database* database = parseDatabase(DBPath);
                    if (!database) {
                        fprintf(stderr, "Cannot load the database from directory '%s'... Exit!\n", DBPath);
                        return EXIT_FAILURE;
                    }

                    // size_t locality = SIZE_MAX; // Ou autre !

                    // printf("Computing...\n");

                    DigitScore digtScore = predictDigit(unknownSignal, database, locality);

                    printf("The detected digit is '%d'!\n", digtScore.digit);
                    printf("The corresponding score is %lf\n", digtScore.score);
                    printf(" (signal  : %s)\n", samplePath);
                    printf(" (database: %s)\n", DBPath);
                    // redondant mais just in case
                    if(digtScore.digit != sampleNumAnalyzed - 48 || digtScore.score < 0 || digtScore.digit == -1){
                        printf("wrong - failed\n");
                        nbreFailed ++;
                    }

                    freeSignal(unknownSignal);
                    freeDatabase(database);

                    printf("--\n");

                } // end for type d'intonation
        } // end for nombre

        printf("NBREFAILED : %d \n", nbreFailed);
        printf("locality : %u \n", locality);


        /*
        if(leastFailed >= nbreFailed){
            leastFailed = nbreFailed;
            bestLocality = locality;
            printf("changed here");
        }
        */


    } // end for locality
    /*
    printf("\n \n BEST LOCALITY : %u", bestLocality);
    printf("\n \n NBRE FAILED : %d", leastFailed);
    */
    return EXIT_SUCCESS;
}
