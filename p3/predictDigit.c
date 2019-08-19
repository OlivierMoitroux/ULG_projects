#include <math.h>
#include <float.h>
#include "Signal.h"
#include "LinkedList.h"
#include "predictDigit.h"
#include "dynamicTimeWarping.h"

DigitScore predictDigit(Signal* signal, Database* database, size_t locality)
{
    DigitScore result;
    double score = DBL_MAX;
    double tmp, comp;
    int digit = -1;
    LLNode* curr;

    for(int i = 0; i < 10; i++)
    {
        curr = database->samples[i]->head;
        for(size_t j = 0;j < database->samples[i]->size; j++)
        {
            tmp     = score;
            comp    = dtw((Signal*)curr->value,signal,locality);
            score   = fmin(score,comp);
            if(score != tmp)
                digit = i;

            curr = curr->next;
        }
    }

    result.digit = digit;
    result.score = score;

    return result;
}
