#include "Holiday.h"
#include "Parsha.h"
#include <stdio.h>

static char *Sfirah(int day);

/*int HolidayFlags = -1;		// all flags are originally set

#define ParshaP   (HolidayFlags & 0x01)
#define OmerP     (HolidayFlags & 0x02)
#define CholP     (HolidayFlags & 0x04)*/

Boolean ParshaP;
Boolean OmerP;
Boolean CholP;

static char *song = "Sh. Shirah";

/* Given a day of the Hebrew month, figuring out all the interesting holidays that
 * correspond to that date.  ParshaP, OmerP, and CholP determine whether we should 
 * given info about the Parsha of the week, the Sfira, or Chol Hamoed.
 * 
 * We are also influenced by the IsraelP flag 
 */

char **
FindHoliday(int month, int day, int weekday, int kvia, 
			Boolean leap_year_p, Boolean israel_p,
			int day_number, int year)
{
	enum { Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday };
	static char *holidays[5];		// The value returned
	char **holiday = holidays;      // a pointer to the next slot to fill
	Boolean shabbat_p = (weekday == Saturday);  // Is it a Saturday?
	holiday[0] = holiday[1] = holiday[2] = holiday[3] = holiday[4] = NULL;

	// Treat Adar in a non-leap year as if it were Adar II.
	if ((month == 12) && !leap_year_p)
		 month = 13;
	switch (month) { 
	    case 1:  /* Nissan */
			switch (day) {
				case 1:
					if (shabbat_p) *holiday++ = "Sh. HaHodesh"; 
					break;
				case 14:
					if (!shabbat_p)  
						// If it's Shabbat, we have three pieces of info. 
						// This is the least important.
						*holiday++ = "Erev Pesach";
					/* Fall thru */
				case 8: case 9: case 10: case 11: case 12: case 13:
					// The Saturday before Pesach (8th-14th)
					if (shabbat_p) *holiday++ = "Sh. HaGadol";
					break;
				case 15: case 16: case 21: case 22:
					if (!israel_p || (day == 15) || (day == 21)) 
						{ *holiday++ = "Pesach"; break;}
					else if (day == 22) break;
					/* else fall through */
				case 17: case 18: case 19: case 20:
					if (CholP) *holiday++ = "Chol Hamoed";
					break;
				case 27: case 28:
					// Yom HaShoah only exists since Israel was established.
					// If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
					if (year > 1948 + 3760) {
						if (year >= 1997 + 3760)
						{
							switch (weekday) {
								case Sunday:
									// If 27, bumped till 28. If 28, we don't care.
									break;
								case Monday:
									*holiday++ = "Yom HaShoah"; // either Monday 27 or bumped from Sunday 27.
									break;
								default:
									if (day == 27) *holiday++ = "Yom HaShoah";
									break;
							}
						}
						else
							if (day == 27) *holiday++ = "Yom HaShoah";
					}
					break; 
			}
			if ((day > 15) && OmerP)
				// Count the Omer, starting after the first day of Pesach.
				*holiday++ = Sfirah(day - 15);
	    	break;

	    case 2:  /* Iyar */
	    	switch (day) {
	    		case 2: case 3: case 4: case 5: case 6:
	    			// Yom HaAtzmaut is on the 5th, unless that's a Saturday, in which
	    			// case it is moved forward two days to Thursday, and unless that's
                    // a Friday in which case it is moved forward one day to Thursday.
                    // Yom HaZikaron is the day before Yom HaAtzmaut.
                    // In 2004 the law changed so that if the 5th is a Monday, Yom
                    // Hazikaron gets moved backward to Tuesday.
                    // http://www.hebcal.com/home/150/yom_haatzmaut_yom_hazikaron_2007
	    			if (year >= 1948 + 3760) {		// only after Israel established.
                        // <Yom HaZikaron> [Yom HaAtzmaut]
                        //   2     3     4     5     6
                        //  Fri   Sat  <Sun> [Mon]  Tue  // < 2004
                        //  Fri   Sat   Sun  <Mon> [Tue] // >= 2004
                        // -Sat---Sun---Mon---Tue---Wed- // does not occur
                        //  Sun   Mon  <Tue> [Wed]  Thu
                        // -Mon---Tue---Wed---Thu---Fri- // does not occur
                        //  Tue  <Wed> [Thu]  Fri   Sat
                        // <Wed> [Thu]  Fri   Sat   Sun
                        // -Thu---Fri---Sat---Sun---Mon- // does not occur
	    				char *zikaron = "Yom HaZikaron";
	    				char *atzmaut = "Yom HaAtzmaut";

                        if (year < 2004 + 3760 && day == 4 && weekday == Sunday)
                            *holiday++ = zikaron;
                        if (year < 2004 + 3760 && day == 5 && weekday == Monday)
                            *holiday++ = atzmaut;

                        if (year >= 2004 + 3760 && day == 5 && weekday == Monday)
                            *holiday++ = zikaron;
                        if (year >= 2004 + 3760 && day == 6 && weekday == Tuesday)
                            *holiday++ = atzmaut;

                        if (day == 4 && weekday == Tuesday)
                            *holiday++ = zikaron;
                        if (day == 5 && weekday == Wednesday)
                            *holiday++ = atzmaut;

                        if (day == 3 && weekday == Wednesday)
                            *holiday++ = zikaron;
                        if (day == 4 && weekday == Thursday)
                            *holiday++ = atzmaut;

                        if (day == 2 && weekday == Wednesday)
                            *holiday++ = zikaron;
                        if (day == 3 && weekday == Thursday)
                            *holiday++ = atzmaut;
		    		}
		    		break;
	    		case 28:
	    			// only since the 1967 war 
	    			if (year > 1967 + 3760) *holiday++ = "Yom Yerushalayim";
	    			break;
	    		case 18: 
	    			*holiday++ = "Lag BaOmer";
	    			break;
	    	}
	    	if ((day != 18) && OmerP)
	    		// Sfirah the whole month.  But Lag BaOmer is already mentioned.
				*holiday++ = Sfirah(day + 15);

	    	break;

	    case 3:  /* Sivan */
	    	switch (day) {
	    		case 1: case 2: case 3: case 4:
	    			// Sfirah until Shavuot
	    			if (OmerP) *holiday++ = Sfirah(day + 44);
	    			break;
	    		case 5:
	    			// Don't need to mention Sfira(49) if there's already two other 
	    			// pieces of information
	    			if (OmerP && !shabbat_p) *holiday++ = Sfirah(49);
	    			*holiday++ = "Erev Shavuot";
	    			break;
	    		case 6: case 7:
	    			if (!israel_p || (day == 6)) *holiday++ = "Shavuot";
	    			break;
	    	}
			break;

	    case 4:  /* Tamuz */
	    	// 17th of Tamuz, except Shabbat pushes it to Sunday.
	    	if ((!shabbat_p && (day == 17)) || ((weekday == 1) && (day == 18))) 
	    		*holiday++ = "Tzom Tamuz"; 
	    	break;

	    case 5:  /* Ab */
	    	if (shabbat_p && (3 <= day) && (day <= 16))
	    		// The shabbat before and after Tisha B'Av are special
	    		*holiday++ = (day <= 9) ? "Sh. Hazon" : "Sh. Nahamu";
	    	else if ((!shabbat_p && (day == 9)) || ((weekday == 1) && (day == 10)))
	    		// 9th of Av, except Shabbat pushes it to Sunday.
	    		*holiday++ = "Tisha B'Av";
	    	break;

	    case 6:  /* Elul */
	    	if ((day >= 20) && (day <= 26) && shabbat_p) *holiday++ = "S'lichot (evening)";
	    	else if (day == 29) *holiday++ = "Erev R.H.";
	   		break;

	   	case 7:  /* Tishrei */
			switch (day) {
				case 1:  case 2: 
					*holiday++ = "Rosh Hashonah";
					break;
				case 3:  
					*holiday++ = shabbat_p ? "Sh. Shuvah" : "Tzom Gedaliah";
					break; 
				case 4:  
					if (weekday == 1) *holiday++ = "Tzom Gedaliah";
					/* fall through */
				case 5: case 6: case 7: case 8: 
					if (shabbat_p) *holiday++ = "Sh. Shuvah";
					break;
				case 9: 
					*holiday++ = "Erev Y.K.";
					break;
				case 10: 
					*holiday++ = "Yom Kippur";
					break;
				case 14: 
					*holiday++ = "Erev Sukkot";
					break;
				case 15: case 16:
					if (!israel_p || (day == 15)) { *holiday++ = "Sukkot"; break; }
					/* else fall through */
				case 17: case 18: case 19: case 20: 
					if (CholP) *holiday++ = "Chol Hamoed"; 
					break;
				case 21: 
					*holiday++ = "Hoshanah Rabah";
					break;
				case 22: 
					*holiday++ = "Shmini Atzeret";
					break;
				case 23: 
					if (!israel_p) *holiday++ = "Simchat Torah";
					break;
			}
			break;
		case 8:  /* Cheshvan */
			break;
			
		case 9:  /* Kislev */
			if (day == 24) *holiday++ = "Erev Hanukah";
			else if (day >= 25) *holiday++ = "Hanukah";
			break;
			
		case 10: /* Tevet */
			if (day <= (kvia == 0 ? 3 : 2)) 
				// Need to know length of Kislev to determine last day of Chanukah
				*holiday++ = "Hanukah";
			else if (((day == 10) && !shabbat_p) || ((day == 11) && (weekday == 1)))
				// 10th of Tevet.  Shabbat pushes it to Sunday
				*holiday++ = "Tzom Tevet";
			break;

		case 11: /* Shvat */
			switch (day) {
				// The info for figuring out Shabbat Shirah is from the Gnu code.  I
				// assume it's correct.
				case 10:
					if ((kvia != 0) && shabbat_p) *holiday++ = song; 
					break;
				case 11: case 12: case 13: case 14: case 16: 
					if (shabbat_p) *holiday++ = song; 
					break;
				case 15:
					if (shabbat_p) *holiday++ = song; 
					*holiday++ = "Tu B'Shvat";
				case 17:
					if ((kvia == 0) && shabbat_p) *holiday++ = song; 
					break;
				case 25: case 26: case 27: case 28: case 29: case 30:
					// The last shabbat on or before 1 Adar or 1 AdarII
					if (shabbat_p && !leap_year_p) *holiday++ = "Sh. Shekalim"; 
					break;
			}	
			break;

		case 12: /* Adar I */
			if (day == 14) 
				// Eat Purim Katan Candy
				*holiday++ = "Purim Katan";
			else if ((day >= 25) && shabbat_p) 
				// The last shabbat on or before 1 Adar II.
				*holiday++ = "Sh. Shekalim"; 
			break;
			
		case 13: /* Adar II or Adar */
			switch (day) {
				case 1:
					if (shabbat_p) *holiday++ = "Sh. Shekalim"; 
					break;
				case 11: case 12:
					// Ta'anit ester is on the 13th.  But shabbat moves it back to
					// Thursday.
					if (weekday == Thursday) *holiday++ = "Ta'anit Ester";
					/* Fall thru */
				case 7: case 8: case 9: case 10: 
					// The Shabbat before purim is Shabbat Zachor
					if (shabbat_p) *holiday++ = "Sh. Zachor";
					break;
				case 13:
					*holiday++ = (shabbat_p ? "Sh. Zachor" : "Erev Purim");
					// It's Ta'anit Esther, unless it's a Friday or Saturday
					if (weekday < Friday) *holiday++ = "Ta'anit Ester";
					break;
				case 14:
					*holiday++ = "Purim";
					break;
				case 15:  
					if (!shabbat_p) *holiday++ = "Shushan Purim";
					break;
				case 16:  
					if (weekday == 1) *holiday++ = "Shushan Purim"; 
					break;
				case 17: case 18: case 19: case 20: case 21: case 22: case 23: 
					if (shabbat_p) *holiday++ = "Sh. Parah";
					break;
				case 24: case 25: case 26: case 27: case 28: case 29:
					if (shabbat_p) *holiday++ = "Sh. HaHodesh"; 
					break;
			}
			break;
	}
	if (shabbat_p && ParshaP)
		// Find the Parsha on Shabbat. 
		*holiday++ = FindParshaName(day_number, kvia, leap_year_p, israel_p);
	return holidays;
}

/* Return a string corresponding to the nth day of the Omer */
static char *
Sfirah(int day)
{
	static char buffer[40];
	char *endings[] = {"th", "st", "nd", "rd"};
	int remainder = day % 10;
	// 11-19 and anything not ending with 1, 2, or 3 uses -th as suffix.
	if ( ((day >= 11) && (day <= 19)) || (remainder > 3)) remainder = 0;
	sprintf(buffer, "%d%s day Omer", day, endings[remainder]);
	return buffer;
}
