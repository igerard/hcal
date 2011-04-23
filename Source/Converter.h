struct DateResult
    { int year;
      int month;
      int day;
      int day_of_week;
      
      int hebrew_month_length, secular_month_length;
      Boolean hebrew_leap_year_p, secular_leap_year_p;
      char *hebrew_month_name, *secular_month_name;
      int kvia;
	  int hebrew_day_number;
};

void SecularToHebrewConversion(int year, int month, int day, Boolean julianp,
							   struct DateResult *result);
void HebrewToSecularConversion(int year, int month, int day, Boolean julianp,
                               struct DateResult *result);
