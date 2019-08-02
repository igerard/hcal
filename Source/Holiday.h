#include <Carbon/Carbon.h>

char **FindHoliday(int month, int day, int weekday, int kvia,
                   bool leap_year_p, bool israel_p,
                   int day_number, int year);

/*extern int HolidayFlags;*/

extern bool ParshaP;
extern bool OmerP;
extern bool CholP;
