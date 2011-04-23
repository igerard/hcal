#include <stdio.h>
#include <string.h>
#include "Dialog.h"
#include "Converter.h"
#include "Holiday.h"
#include "Prefs.h"

#define PREVIOUS_MONTH_CONTROL 1
#define NEXT_MONTH_CONTROL     2

#define CALENDAR_WINDOW_RESOURCE_ID 128

#define FONT kFontIDGeneva

static void DrawCenteredAtPoint(char *buffer, int x, int y);
static void DoPrinting();
static pascal void sheetDone(PMPrintSession printSession, WindowRef window, Boolean accepted);
static void PrintError(OSStatus status);
static void RedrawWeekDays(void);
static void FillInCalendar(int year, int month);
static void DoTheOutput(int column, int row, int day, int j_year,
            char *j_month_name, int j_day, char **holidays);
 
// The following data is exported
int	CurrentMonth, CurrentYear;
int				MinYear = 1;
int				MaxYear = 2999;
Boolean			JulianP = FALSE;
Boolean			IsraelP = FALSE;

PMPrintSession	printSession = nil;
PMPageFormat	pageFormat = nil;
PMPrintSettings	printSettings = nil;
Boolean			isPrintDialog = false;
PMSheetDoneUPP	sheetDoneUPP();

static WindowPtr  CalendarWindow;
static Rect		  InfoRect, ErasableRect;
static int		  DateBoxWidth, DateBoxHeight, DateBoxLeft, DateBoxTop;
static int		  WeekdayInfoTop, WeekdayInfoBottom;
static Point      InfoPoint;
static Str15      DayNames[7] = {"\pSunday", "\pMonday", "\pTuesday", "\pWednesday",
								"\pThursday", "\pFriday", "\pSaturday"};
static ControlHandle     PreviousMonthControlHandle, NextMonthControlHandle;

/* Called to initialize the Calendar Window */
void
InitializeDialogWindow()
{	unsigned long	seconds;
	DateTimeRec 	DateTime;
	Rect			rect;
	
	int 			WindowHeight, WindowWidth;
	int				WindowPictureLeft, WindowPictureRight;//, WindowPictureWidth;


#ifdef INTERNATIONAL
	Intl1Hndl		IntHandle;
	/* Get the internation day and month names */
	IntHandle = (Intl1Hndl)IUGetIntl(1);
	memcpy(MonthNames, (**IntHandle).months, (long)sizeof(MonthNames));
	memcpy(DayNames, (**IntHandle).days, (long)sizeof(DayNames));
	DisposHandle(IntHandle);
#endif
	
	// Get the current month and year.  Use these as the initial values.
	GetDateTime(&seconds);
	SecondsToDate(seconds, &DateTime);
	CurrentMonth = DateTime.month;
	CurrentYear = DateTime.year;
	
	// Create the window from the resource description.  Get its size.
	CalendarWindow = GetNewCWindow(CALENDAR_WINDOW_RESOURCE_ID, NULL, kFirstWindowOfClass);
	ShowWindow(CalendarWindow);
	GetWindowPortBounds(CalendarWindow, &rect);
	WindowHeight = rect.bottom - rect.top;
	WindowWidth = rect.right - rect.left;
	
	// Divide the window into regions.  First get the useful boundaries.
	WindowPictureLeft = 3 + rect.left;
	WindowPictureRight = (WindowWidth - 3);
#define INFO_TOP 4
#define INFO_BOTTOM (INFO_TOP + 30)
#define NEXT_WIDTH 130
#define NEXT_HEIGHT 20
#define PREV_BUTTON 128
#define NEXT_BUTTON 129

	PreviousMonthControlHandle = GetNewControl(PREV_BUTTON, CalendarWindow);
	NextMonthControlHandle = GetNewControl(NEXT_BUTTON, CalendarWindow);
						
	// InfoRect is in between the two buttons.  We put month stuff there
	SetRect(&InfoRect, WindowPictureLeft + NEXT_WIDTH, INFO_TOP, 
	                   WindowPictureRight - NEXT_WIDTH, INFO_BOTTOM);
	SetPt(&InfoPoint, (WindowPictureLeft + WindowPictureRight)/2, INFO_TOP + 10);
						
	// Where to put the weekday information.
#define WEEKDAY_INFO_HEIGHT 20
	WeekdayInfoTop = INFO_BOTTOM + 4;
	WeekdayInfoBottom = WeekdayInfoTop + WEEKDAY_INFO_HEIGHT;

	// EraseableRect contains the actual calendar information.
	SetRect(&ErasableRect, 0, INFO_BOTTOM+20, 
	                       WindowWidth, WindowHeight);
	                       
	// Divide this area into a grid of 7 columns and 6 rows.						
	DateBoxLeft = WindowPictureLeft;  
	DateBoxWidth = (WindowPictureRight - WindowPictureLeft) / 7;
	DateBoxTop = WeekdayInfoBottom; 
	DateBoxHeight = (WindowHeight - DateBoxTop - 2)/6;
}
		
						
/* Handle a click in the NEXT MONTH or PREVIOUS MONTH button */

void
HandleControlItem (Point EventPoint, short partcode, ControlHandle whichControl)
{
	int	ControlInfo = GetControlReference(whichControl);
	if (TrackControl(whichControl, EventPoint, NULL)) {
		if (ControlInfo == PREVIOUS_MONTH_CONTROL) {
			if (--CurrentMonth == 0)  CurrentMonth = 12, CurrentYear--;
		} else {
			if (++CurrentMonth == 13) CurrentMonth = 1, CurrentYear++;
		}
		RedrawCalendarWindow();
	}
}

/* The window manager wants us to update a piece of the window */

void
UpdateEventCalendarWindow(EventRecord *theEvent)
{
	WindowPtr whichWindow;
	
	whichWindow = (WindowPtr)theEvent->message;
	SetPort(GetWindowPort(whichWindow));
	BeginUpdate(whichWindow);
	if (whichWindow == CalendarWindow)
	{
		RedrawCalendarWindow();
		DrawControls(whichWindow);
	}
	EndUpdate(whichWindow);
}

void PageSetup()
{
	CFPropertyListRef	dataBlob;
	OSStatus			status = noErr;
	
	Boolean				closeSession = false,
						canDoSheets = true,
						haveValid = false,
						accepted;
	
	// Start a session
	
	status = PMCreateSession(&printSession);
	if (status)
		goto egress;
	
	closeSession = true;
	
	status = PMSessionUseSheets(printSession, CalendarWindow, sheetDoneUPP());
	if (status)
		if (status == kPMNotImplemented)
			canDoSheets = false;
		else
			goto egress;
	
	// Get the saved pageFormat
	
	dataBlob = CFPreferencesCopyAppValue(kPageSetupPrefRef, kCFPreferencesCurrentApplication);
	if (dataBlob)
	{
		if (CFGetTypeID(dataBlob) == CFDataGetTypeID())
		{
			// extract
			Handle flatFormat;
			PtrToHand(CFDataGetBytePtr(dataBlob), &flatFormat, CFDataGetLength(dataBlob));
			PMUnflattenPageFormat(flatFormat, &pageFormat);
			DisposeHandle(flatFormat);
			haveValid = true;
		}
		
		CFRelease(dataBlob);
	}
	
	// Create if necessary, validate
	
	if (haveValid)
	{
		status = PMSessionValidatePageFormat(printSession, pageFormat, &accepted);
		if (status)
			goto egress;
	}
	else
	{
		status = PMCreatePageFormat(&pageFormat);
		if (status)
			goto egress;
		
		status = PMSessionDefaultPageFormat(printSession, pageFormat);
		if (status)
			goto egress;
	}
	
	// Put up the dialog
	
	isPrintDialog = false;
	
	status = PMSessionPageSetupDialog(printSession, pageFormat, &accepted);
	
	// Deal with it
	
	if (canDoSheets)
		closeSession = false; // callback will close
	
	if (!canDoSheets && accepted)
	{
		closeSession = false; // callback will close
		sheetDone(printSession, CalendarWindow, accepted);
	}
	
egress:
	
	if (closeSession)
	{
		if (printSettings)
		{
			PMRelease(printSettings);
			printSettings = nil;
		}
		
		if (pageFormat)
		{
			PMRelease(pageFormat);
			pageFormat = nil;
		}

		(void) PMRelease(printSession);
		printSession = nil;
	}
	
	if (status != noErr)
	{
		PrintError(status);
		return;
	}
}

/* Print the current month */
void 
PrintCalendar ()
{
	CFPropertyListRef	dataBlob;
	OSStatus			status = noErr;
	
	Boolean				closeSession = false,
						canDoSheets = true,
						haveValid = false,
						accepted;
	
	// Start a session
	
	status = PMCreateSession(&printSession);
	if (status)
		goto egress;
	
	closeSession = true;
	
	status = PMSessionUseSheets(printSession, CalendarWindow, sheetDoneUPP());
	if (status)
		if (status == kPMNotImplemented)
			canDoSheets = false;
		else
			goto egress;
	
	// Get the saved pageFormat
	
	dataBlob = CFPreferencesCopyAppValue(kPageSetupPrefRef, kCFPreferencesCurrentApplication);
	if (dataBlob)
	{
		if (CFGetTypeID(dataBlob) == CFDataGetTypeID())
		{
			// extract
			Handle flatFormat;
			PtrToHand(CFDataGetBytePtr(dataBlob), &flatFormat, CFDataGetLength(dataBlob));
			PMUnflattenPageFormat(flatFormat, &pageFormat);
			DisposeHandle(flatFormat);
			haveValid = true;
		}
		
		CFRelease(dataBlob);
	}
	
	// Create if necessary, validate
	
	if (haveValid)
	{
		status = PMSessionValidatePageFormat(printSession, pageFormat, &accepted);
		if (status)
			goto egress;
	}
	else
	{
		status = PMCreatePageFormat(&pageFormat);
		if (status)
			goto egress;
		
		status = PMSessionDefaultPageFormat(printSession, pageFormat);
		if (status)
			goto egress;
	}
	
	// Set up a PrintSettings object
	
	status = PMCreatePrintSettings(&printSettings);
		
	if (status == noErr)
		status = PMSessionDefaultPrintSettings(printSession, printSettings);
	
    //  Display the Print dialog.
    
    PMSetJobNameCFString(printSettings, CFSTR("Jewish Calendar"));
    
    if (status == noErr)
    {
		isPrintDialog = true;
		
		status = PMSessionPrintDialog(printSession, printSettings, pageFormat, &accepted);
	}
	
	// Deal with it
	
	if (canDoSheets)
		closeSession = false; // callback will close
	
	if (!canDoSheets && accepted)
	{
		closeSession = false; // callback will close
		sheetDone(printSession, CalendarWindow, accepted);
	}
	
egress:

	if (closeSession)
	{
		if (printSettings)
		{
			PMRelease(printSettings);
			printSettings = nil;
		}
		
		if (pageFormat)
		{
			PMRelease(pageFormat);
			pageFormat = nil;
		}

		(void) PMRelease(printSession);
		printSession = nil;
	}
	
	if (status != noErr)
	{
		PrintError(status);
		return;
	}
}

void DoPrinting()
{
	OSStatus status;
	
	status = PMSessionBeginDocument(printSession, printSettings, pageFormat);
	if (status != noErr)
		return;
	
	do
	{
		CGrafPtr oldPort;
		CGrafPtr printPort;
	
		status = PMSessionBeginPage(printSession, pageFormat, nil);
		if (status != noErr)
			break;
		
		status = PMSessionGetGraphicsContext(printSession, kPMGraphicsContextQuickdraw, (void **)&printPort);
		if (status != noErr)
			break;
		
		GetPort(&oldPort);
		SetPort(printPort);
		
		RedrawCalendarWindow();
		SetPort(oldPort);
		
		status = PMSessionEndPage(printSession);
	} while (0);
	
	(void) PMSessionEndDocument(printSession);
}

PMSheetDoneUPP sheetDoneUPP()
{
	static PMSheetDoneUPP sProc = nil;
	
	if (!sProc)
		sProc = NewPMSheetDoneUPP(sheetDone);
	
	return sProc;
}

pascal void sheetDone(PMPrintSession printSession, WindowRef window, Boolean accepted)
{
	if (accepted)
	{
		if (isPrintDialog)
		{
			DoPrinting();
		}
		else
		{
			CFDataRef blob;
			Handle flatFormat;
			PMFlattenPageFormat(pageFormat, &flatFormat);
			HLock(flatFormat);
			blob = CFDataCreate(kCFAllocatorDefault, (UInt8*)*flatFormat, GetHandleSize(flatFormat));
			CFPreferencesSetAppValue(kPageSetupPrefRef, blob, kCFPreferencesCurrentApplication);
			CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
			CFRelease(blob);
			DisposeHandle(flatFormat);
		}
	}
	
	// Close the session
	if (printSettings)
	{
		PMRelease(printSettings);
		printSettings = nil;
	}
	
	if (pageFormat)
	{
		PMRelease(pageFormat);
		pageFormat = nil;
	}
	
	(void) PMRelease(printSession);
	printSession = nil;
}

void PrintError(OSStatus status)
{
	Str255 statString;

	if (status == kPMCancel)
		return; // the user _knows_ they cancelled....
	
	NumToString(status, statString);
	ParamText(statString, NULL, NULL, NULL);
	StopAlert(131, NULL);
}

/* Redraw the current calendar. */
void	
RedrawCalendarWindow()
{
	// Figure out if nextmonth and previous month should be hilighted or not.
	HiliteControl(PreviousMonthControlHandle, 
				      (CurrentYear == MinYear && CurrentMonth == 1) ? 255 : 0);
	HiliteControl(NextMonthControlHandle,
				      (CurrentYear == MaxYear && CurrentMonth == 12) ? 255 : 0);

	// Erase pieces of the screen
	EraseRect(&InfoRect);	
	EraseRect(&ErasableRect);

	// Redraw the weekdays, and the rest of the stuff
	RedrawWeekDays();
	FillInCalendar(CurrentYear, CurrentMonth);
}


static void
RedrawWeekDays()
{	
	Rect		box;
	int			i;
	
	TextFont(0);
	TextSize(0);
	for(i=0; i<=6; i++) {
		SetRect(&box, DateBoxLeft + i*DateBoxWidth, WeekdayInfoTop,
		              DateBoxLeft + (i+1)*DateBoxWidth, WeekdayInfoBottom);
		TETextBox(DayNames[i] + 1, 3, &box, teJustCenter);
	}
}
					  
static void FillInMonth(char *, int, const char *);

/* Fill in the calendar for the given secular year and month. */
static void
FillInCalendar(int secular_year, int secular_month)
{
    struct DateResult result;
    int row, column;
    int days_in_secular_month, days_in_hebrew_month;
    int secular_day, hebrew_day, hebrew_month, hebrew_year;
    int hebrew_kvia, hebrew_day_number;
    Boolean hebrew_leap_year_p;
    char *hebrew_month_name, **holidays;
    int initial_hebrew_day, final_hebrew_day;
    int initial_hebrew_year, final_hebrew_year;
    char *initial_hebrew_month, *final_hebrew_month, buffer[100];
  
 	SecularToHebrewConversion(secular_year, secular_month, 1, JulianP, &result);
    days_in_secular_month = result.secular_month_length;
    column = result.day_of_week;
   // Print the header, with the month name
    FillInMonth(result.secular_month_name, secular_year, JulianP ? " (Julian)" : "");
	
	// Fill in each day of the calendar	
	TextFont(FONT);
	TextSize(9);
    for (row = 0, secular_day = 1; secular_day <= days_in_secular_month;) {
		// at this point, we're either on the first day of the secular month, or
		// the first day of the Hebrew month.
 		if (secular_day > 1) 
 			SecularToHebrewConversion(secular_year, secular_month, secular_day, JulianP, &result);
    	days_in_hebrew_month = result.hebrew_month_length;
     	hebrew_day = result.day;
    	hebrew_month = result.month;
    	hebrew_year = result.year;

    	hebrew_leap_year_p = result.hebrew_leap_year_p;
    	hebrew_kvia = result.kvia;
    	hebrew_month_name = result.hebrew_month_name;
    	hebrew_day_number = result.hebrew_day_number;
    	if (secular_day == 1) {
    		// remember info about the first day of the secular month
    		initial_hebrew_day = hebrew_day;
    		initial_hebrew_year = hebrew_year;
    		initial_hebrew_month = hebrew_month_name;
    	}
    	while ((secular_day <= days_in_secular_month) && 
    		   (hebrew_day <= days_in_hebrew_month)) {
    	    holidays = FindHoliday(hebrew_month, hebrew_day, column+1, 
    						       hebrew_kvia, hebrew_leap_year_p, IsraelP,
    						       hebrew_day_number, hebrew_year);
   			DoTheOutput(column, row, secular_day,
		                   hebrew_year, hebrew_month_name, hebrew_day, holidays);
		    if (secular_day == days_in_secular_month) {
		    	// remember information about the last day of the month
    			final_hebrew_day = hebrew_day;
    			final_hebrew_year = hebrew_year;
    			final_hebrew_month = hebrew_month_name;
    		}
			secular_day++; hebrew_day++; hebrew_day_number++;
			// increment the column.  Go to the next row if it's Saturday.
			if (++column == 7) 
				{ column = 0; row++; }
       	    }
        }
    if (initial_hebrew_month == final_hebrew_month)  // only in February
    	buffer[0] = sprintf(buffer+1, "%d Ñ %d %s  %d", initial_hebrew_day,
    			            final_hebrew_day, final_hebrew_month, final_hebrew_year);
    else if (initial_hebrew_year == final_hebrew_year) 
    	// different month, same year.
    	buffer[0] = sprintf(buffer+1, "%d %s Ñ %d %s  %d",
    						initial_hebrew_day, initial_hebrew_month,
    					    final_hebrew_day, final_hebrew_month, final_hebrew_year);
    else
    	// we've crossed a year boundary
    	buffer[0] = sprintf(buffer+1, "%d %s %d Ñ %d %s %d",
    					    initial_hebrew_day, initial_hebrew_month, initial_hebrew_year,
    					    final_hebrew_day, final_hebrew_month, final_hebrew_year);
    TextFont(0);
    TextSize(0);
    DrawCenteredAtPoint(buffer, InfoPoint.h, InfoPoint.v + 15);
}

/* Print info about this month centered in the info rectangle */					
static void
FillInMonth(char *month_name, int year, const char *extra)
{
	char buffer[100];
	buffer[0] = sprintf(buffer + 1, "%s %d%s", month_name, year, extra); 
	TextFont(0);
	TextSize(0);	
	DrawCenteredAtPoint(buffer, InfoPoint.h, InfoPoint.v);
}	

/* Collect all the information we've learned about a particular day and print it 
 * into a box.
 */
 
void
DoTheOutput(int column, int row, int day, int j_year, 
            char *j_month_name, int j_day, char **holidays)
{
	Rect 	box;
	int		top, left, center;
	char     buffer[200];

	// Figure where this information goes in the calendar.
	top	= DateBoxTop + row * DateBoxHeight;
	left = DateBoxLeft + column * DateBoxWidth;
	center = left + DateBoxWidth / 2;
	SetRect(&box, left, top, left+DateBoxWidth + 1, top+DateBoxHeight + 1);
	EraseRect(&box);

	// Print the secular day of the month in bold
	TextFace(1);					// what is the constant?
	buffer[0] = sprintf(buffer+1, "%d", day);  
	DrawCenteredAtPoint(buffer, center, top + 9);
	TextFace(0);
	
	// Print the Hebrew day just below it
	buffer[0] = sprintf(buffer+1, "%d %s", j_day, j_month_name);
	DrawCenteredAtPoint(buffer, center, top + 18);
	
	if (holidays[1] != NULL) {
		// If there are more than two holidays, print both of them
		buffer[0] = sprintf(buffer+1, "%s", holidays[0]);
		DrawCenteredAtPoint(buffer, center, top + 27);
		buffer[0] = sprintf(buffer+1, "%s", holidays[1]);
		DrawCenteredAtPoint(buffer, center, top + 36);
	} else if (holidays[0] != NULL) {
		// If there is only one holiday, see if one of them is a double parsha that
		// is too long to fit on one line
		char *slash_ptr = strchr(holidays[0], '/');
		buffer[0] = sprintf(buffer + 1, "%s", holidays[0]);
		if ((slash_ptr == NULL) || (StringWidth((unsigned char *)buffer) < DateBoxWidth)) 
			// nope, just print it.
			DrawCenteredAtPoint(buffer, center, top+30);
		else {
			// Divide the parsha into two.  Print left justified and right justified
			*slash_ptr = '\0';
			buffer[0] = sprintf(buffer+1, "%s/", holidays[0]);
			MoveTo(left, top + 27);
			DrawString((unsigned char *)buffer);
			buffer[0] = sprintf(buffer+1, "%s", slash_ptr+1);
			MoveTo(left + DateBoxWidth - StringWidth((unsigned char *)buffer), top + 36);
			DrawString((unsigned char *)buffer);
		}
	}
	// Draw a line around the box	
	FrameRect(&box);
}

/* Print the given Pascal string centered at the given point. */

static void
DrawCenteredAtPoint(char *string, int h, int v)
{
	h -= StringWidth((unsigned char *)string) / 2;
	MoveTo(h, v);
	DrawString((unsigned char *)string);
}
