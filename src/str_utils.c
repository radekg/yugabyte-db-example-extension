#include "postgres.h"
#include "include/str_utils.h"

char *
str_to_lower(char *in)
{
    char *out;
    int idx;
    out = pstrdup(in);
    for (idx = 0; out[idx]; idx++)
        out[idx] = (char)pg_tolower((unsigned char)out[idx]);
    return out;
}