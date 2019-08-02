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
