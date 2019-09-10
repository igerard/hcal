#include <Carbon/Carbon.h>

struct DateResult
{
  int year;
  int month;
  int day;
  int day_of_week;
  
  int hebrew_month_length;
  int secular_month_length;
  bool hebrew_leap_year_p;
  bool secular_leap_year_p;
  char *hebrew_month_name;
  char *secular_month_name;
  int kvia;
  int hebrew_day_number;
};

struct DateResult SecularToHebrewConversion(int year, int month, int day, bool julianp);
struct DateResult HebrewToSecularConversion(int year, int month, int day, bool julianp);

// Utilities

extern long absolute_from_gregorian(int year, int month, int day);

/* Given a julian date, calculate the number of days since January 0, 0000
 * (Gregorian)
 */
extern long absolute_from_julian (int year, int month, int day);

/* Given a Hebrew date, calculate the number of days since
 * January 0, 0001, Gregorian
 */
extern long absolute_from_hebrew (int year, int month, int day);
      
/* Given an absolute date, calculate the gregorian date  */
extern void gregorian_from_absolute (long date, int *yearp, int *monthp, int *dayp);

/* Given an absolute date, calculate the Julian date. */
extern void julian_from_absolute (long date, int *yearp, int *monthp, int *dayp);

/* Given an absolute date, calculate the Hebrew date */
extern void hebrew_from_absolute(long date, int *yearp, int *monthp, int *dayp);
  
/* Number of months in a Hebrew year */
int hebrew_months_in_year(int year);

/* Number of days in a Hebrew month */
extern int hebrew_month_length(int year, int month);

/* Number of days in a Julian or gregorian month */
extern int secular_month_length(int year, int month, bool julianp);

/* Is it a Leap year in the gregorian calendar */
extern bool gregorian_leap_year_p(int year);

/* Is it a leap year in the Julian calendar */
extern bool julian_leap_year_p(int year);

/* Is it a leap year in the Jewish Calendar */
extern bool hebrew_leap_year_p(int year);

/* Return the number of days from 1 Tishrei 0001 to the beginning of the given year.
 * Since this routine gets called frequently with the same year arguments, we cache
 * the most recent values.
 */
extern long hebrew_elapsed_days(int year);

extern long hebrew_elapsed_days2(int year);

/* Number of days in the given Hebrew year */
extern int hebrew_year_length(int year);

