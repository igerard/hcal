#include "Parsha.h"
#include <stdio.h>

// The names of the Parshiot.
static char *parshiot_names[] = 
{
  "Bereshit",    "Noach",       "Lech L'cha", "Vayera",      "Chaye Sarah",
  "Toldot",      "Vayetze",     "Vayishlach", "Vayeshev",    "Miketz",
  "Vayigash",    "Vayechi",     "Shemot",     "Vaera",       "Bo", 
  "Beshalach",   "Yitro",       "Mishpatim",  "Terumah",     "Tetzaveh", 
  "Ki Tisa" ,    "Vayakhel",    "Pekudei",    "Vayikra",     "Tzav",
  "Shemini",     "Tazria",      "Metzora",    "Acharei Mot", "Kedoshim",
  "Emor",        "Behar",       "Bechukotai", "Bemidbar",    "Naso", 
  "Behaalotcha", "Shelach",     "Korach",     "Chukat",      "Balak",
  "Pinchas",     "Matot",       "Masei",      "Devarim",     "Vaetchanan",
  "Ekev",        "Reeh",        "Shoftim",    "Ki Tetze",    "Ki Tavo",
  "Nitzavim",    "Vayelech",    "Haazinu", };


// Tables for each of the year types.  XX indicates that it is a Holiday, and
// a special parsha is read that week.  For some year types, Israel is different
// than the diaspora.
//
// The names indicate the day of the week on which Rosh Hashanah fell, whether
// it is a short/normal/long year (kvia=0,1,2), and whether it is a leap year.  
// Some year types also have an _Israel version.
//
// Numbers are indices into the table above for a given week.  Numbers > 100 indicate
// a double parsha.  E.g. 150 means read both table entries 50 and 51.
// 
// These tables were stolen (with some massaging) from the GNU code.

#define XX 255
static unsigned const char Sat_short[] =	
 {  XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25,
   126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,};

static unsigned const char Sat_long[] =
 {  XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25,
   126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49, 150,};

static unsigned const char Mon_short[] = 
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
   128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,  45,
    46,  47,  48,  49, 150,};

static unsigned const char Mon_long[] = /* split */
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
   128,  30, 131,  33,  XX,  34,  35,  36,  37, 138,  40, 141,  43,  44,  45,
    46,  47,  48,  49, 150,};
#define Mon_long_Israel Mon_short

#define Tue_normal  Mon_long
#define Tue_normal_Israel  Mon_short

static unsigned const char Thu_normal[] =
 {  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  XX,  25,
   126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,};
static unsigned const char Thu_normal_Israel[] = 
 {  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
   128,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,};

static unsigned const char Thu_long[] = 
 {  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  XX,  25,
   126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,};

static unsigned const char Sat_short_leap[] =
 {  XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,
    26,  27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
    40, 141,  43,  44,  45,  46,  47,  48,  49, 150,};

static unsigned const char Sat_long_leap[] = 
 {  XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,
    26,  27,  XX,  28,  29,  30,  31,  32,  33,  XX,  34,  35,  36,  37, 138,
    40, 141,  43,  44,  45,  46,  47,  48,  49, 150,};
#define Sat_long_leap_Israel  Sat_short_leap


static unsigned const char Mon_short_leap[] = 
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  XX,  34,  35,  36,  37, 138,  40,
   141,  43,  44,  45,  46,  47,  48,  49, 150,};
static unsigned const char Mon_short_leap_Israel[] = 
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
   141,  43,  44,  45,  46,  47,  48,  49, 150,};

static unsigned const char Mon_long_leap[] = 
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
    40, 141,  43,  44,  45,  46,  47,  48,  49,  50,};
static unsigned const char Mon_long_leap_Israel[] = 
 {  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49,  50,};

#define Tue_normal_leap  Mon_long_leap
#define Tue_normal_leap_Israel  Mon_long_leap_Israel


static unsigned const char Thu_short_leap[] =
 {  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  28,  XX,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49,  50,};
 
static unsigned const char Thu_long_leap[] = 
 {  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  28,  XX,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49, 150,};
 
/* Find the parsha for a given day of the year.  daynumber is the day of the year.
 * kvia and leap_p refer to the year type. 
 */
 
char *
FindParshaName(int daynumber, int kvia, Boolean leap_p, Boolean israel_p)
{
	int week = daynumber/7;				// week of the year
	unsigned const char *array = NULL;
	int index;

	// get the appropriate array by exhaustive search into the 14 year types.  Since we 
	// know it's a Shabbat, we can find out what day Rosh Hashanah was on by looking
	// at daynumber %7.
	if (!leap_p) {
		switch (daynumber % 7) {
		case 1:  /* RH was on a Saturday */
			if (kvia == 0)       array = Sat_short;
			else if (kvia == 2)  array = Sat_long;
			break;
	 	case 6:  /* RH was on a Monday */
	 		if (kvia == 0)       array = Mon_short;
	 		else if (kvia == 2)  array = israel_p ? Mon_long_Israel : Mon_long;
	 		break;
	 	case 5:  /* RH was on a Tueday */
	 		if (kvia == 1) 	 	 array = israel_p ? Tue_normal_Israel : Tue_normal;
	 		break;
		case 3:  /* RH was on a Thu */
			if (kvia == 1)		array = israel_p ? Thu_normal_Israel : Thu_normal;
			else if (kvia == 2) array = Thu_long;
			break;
		}
	} else /* leap year */
		switch (daynumber % 7) {
		case 1:  /* RH was on a Sat */
			if (kvia == 0)      array = Sat_short_leap;
			else if (kvia == 2) array = israel_p ? Sat_long_leap_Israel : Sat_long_leap;
			break;
	 	case 6:  /* RH was on a Mon */
	 		if (kvia == 0)      array = israel_p ? Mon_short_leap_Israel : Mon_short_leap;
	 		else if (kvia == 2) array = israel_p ? Mon_long_leap_Israel : Mon_long_leap;
	 		break;
	 	case 5:  /* RH was on a Tue */
	 		if (kvia == 1)      array = israel_p ? Tue_normal_leap_Israel : Tue_normal_leap;
	 		break;
		case 3:  /* RH was on a Thu */
			if (kvia == 0)      array = Thu_short_leap;
			else if (kvia == 2) array = Thu_long_leap;
			break;
		}
	if (array == NULL)
		/* Something is terribly wrong. */ 
		return "??Parsha??";
	index = array[week];
	if (index == XX) 				// no Parsha this week.
		return NULL;
	else if (index < 100)
		return parshiot_names[index];
	else {							// Create a double parsha
		static char buffer[100];
		sprintf(buffer, "%s/%s", 
				parshiot_names[index - 100], parshiot_names[index - 99]);
	    return buffer;
	}
}

