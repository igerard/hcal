#include <Carbon/Carbon.h>

struct DateResult
{
  long year;
  long month;
  long day;
  long day_of_week;

  long  hebrew_month_length;
  long  secular_month_length;
  bool  hebrew_leap_year_p;
  bool  secular_leap_year_p;
  char* hebrew_month_name;
  char* secular_month_name;
  long  kvia;
  long  hebrew_day_number;
};

struct DateResult SecularToHebrewConversion(long year, long month, long day, bool julianp);
struct DateResult HebrewToSecularConversion(long year, long month, long day, bool julianp);

// Utilities

extern long absolute_from_gregorian(long year, long month, long day);

/* Given a julian date, calculate the number of days since January 0, 0000
 * (Gregorian)
 */
extern long absolute_from_julian (long year, long month, long day);

/* Given a Hebrew date, calculate the number of days since
 * January 0, 0001, Gregorian
 */
extern long absolute_from_hebrew (long year, long month, long day);

/* Given an absolute date, calculate the gregorian date  */
extern void gregorian_from_absolute (long date, long *yearp, long *monthp, long *dayp);

/* Given an absolute date, calculate the Julian date. */
extern void julian_from_absolute (long date, long *yearp, long *monthp, long *dayp);

/* Given an absolute date, calculate the Hebrew date */
extern void hebrew_from_absolute(long date, long *yearp, long *monthp, long *dayp);

/* Number of months in a Hebrew year */
long hebrew_months_in_year(long year);

/* Number of days in a Hebrew month */
extern long hebrew_month_length(long year, long month);

/* Number of days in a Julian or gregorian month */
extern long secular_month_length(long year, long month, bool julianp);

/* Is it a Leap year in the gregorian calendar */
extern bool gregorian_leap_year_p(long year);

/* Is it a leap year in the Julian calendar */
extern bool julian_leap_year_p(long year);

/* Is it a leap year in the Jewish Calendar */
extern bool hebrew_leap_year_p(long year);

/* Return the number of days from 1 Tishrei 0001 to the beginning of the given year.
 * Since this routine gets called frequently with the same year arguments, we cache
 * the most recent values.
 */
extern long hebrew_elapsed_days(long year);

extern long hebrew_elapsed_days2(long year);

/* Number of days in the given Hebrew year */
extern long hebrew_year_length(long year);

