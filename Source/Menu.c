#include "Menu.h"
#include "Dialog.h"
#include "Holiday.h"
#include "Prefs.h"
#include "Globals.h"
#include "GetVersNumString.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

void UpdateMenuSelection();


#define APPLE_MENU 128
#define FILE_MENU 129
#define AQUA_FILE_MENU 229
#define EDIT_MENU 130
#define OPTION_MENU 131
#define MONTH_MENU 132
#define YEAR_MENU 133

#define MENU_BAR 128
#define AQUA_MENU_BAR 129

#define ABOUT_DIALOG 128
#define YEAR_DIALOG 129
#define ILLEGAL_YEAR_ALERT 130

static void AboutJewishCalendarWindow(void);
static void NewYearWindow(void);
pascal void IncrementDecrementYear(ControlHandle controlHdl, short partCode);
static pascal Boolean EventFilter(DialogPtr dialogPtr, EventRecord *theEvent, short *itemHit);
static pascal ControlKeyFilterResult NumericFilter(ControlHandle control, short* keyCode,
	short *charCode, unsigned short *modifiers);

Boolean gInYearDialog = FALSE;
Boolean gInAboutDialog = FALSE;
ControlHandle gLittleArrows;
ControlHandle gEditBoxHandle;

MenuHandle  DeskMenu, FileMenu, EditMenu, OptionMenu, MonthMenu, YearMenu;
PicHandle  	DownPicture, SamePicture, UpPicture;

/* Called at the beginning of the program to initialize the menu bar 
 */
 
void SetUpMenus()
{
	long response;
	Handle myMenuBar;
	
	// Get the menu bar from the resource
	Gestalt(gestaltMenuMgrAttr, &response);
	if (response & gestaltMenuMgrAquaLayoutMask)
		myMenuBar = GetNewMBar(AQUA_MENU_BAR);
	else
		myMenuBar = GetNewMBar(MENU_BAR);
	SetMenuBar(myMenuBar);

	// Get pointers to each of the menus.  We'll need them.
	DeskMenu = GetMenuHandle(APPLE_MENU);
	if (response & gestaltMenuMgrAquaLayoutMask)
		FileMenu = GetMenuHandle(AQUA_FILE_MENU);
	else
		FileMenu = GetMenuHandle(FILE_MENU);
	EditMenu = GetMenuHandle(EDIT_MENU);
	OptionMenu = GetMenuHandle(OPTION_MENU);
	MonthMenu = GetMenuHandle(MONTH_MENU);
	YearMenu = GetMenuHandle(YEAR_MENU);

//	ChangeMenuAttributes(FileMenu, kMenuAttrAutoDisable, 0);

	DrawMenuBar();
}


/* Called when a menu item has been selected */
void
doMenu(long menuResult)
{
	short menuID = HiWord(menuResult);
	short itemNumber =  LoWord(menuResult);
	switch (menuID) {
		case APPLE_MENU:
			if (itemNumber == 1) 
				AboutJewishCalendarWindow();
			break;
			
		case FILE_MENU:
		case AQUA_FILE_MENU:
			switch (itemNumber) {
				case 1:  PageSetup(); break;	// page setup
				case 2:  PrintCalendar(); break;	// print
				case 4:  gAreWeDoneYet = true; break; // exit
			}
			break;
		
		case OPTION_MENU:
			switch (itemNumber) {
				case 1: // Gregorian
					JulianP = FALSE;
					CFPreferencesSetAppBooleanValue(kJulianCalendarPrefRef,
													kCFPreferencesCurrentApplication,
													false);
					break;
				
				case 2: // Julian
					JulianP = TRUE;
					CFPreferencesSetAppBooleanValue(kJulianCalendarPrefRef,
													kCFPreferencesCurrentApplication,
													true);
					break;
				
				case 4: // Diaspora
					IsraelP = FALSE;
					CFPreferencesSetAppBooleanValue(kIsraelPrefRef,
													kCFPreferencesCurrentApplication,
													false);
					break;
				
				case 5: // Israel
					IsraelP = TRUE;
					CFPreferencesSetAppBooleanValue(kIsraelPrefRef,
													kCFPreferencesCurrentApplication,
													true);
					break;
				
				case 7: // Parsha
					ParshaP = !ParshaP;
					CFPreferencesSetAppBooleanValue(kParshaPrefRef,
													kCFPreferencesCurrentApplication,
													ParshaP);
					break;
				
				case 8: // Omer
					OmerP = !OmerP;
					CFPreferencesSetAppBooleanValue(kOmerPrefRef,
													kCFPreferencesCurrentApplication,
													OmerP);
					break;
				
				case 9: // Chol
					CholP = !CholP;
					CFPreferencesSetAppBooleanValue(kCholHamoedPrefRef,
													kCFPreferencesCurrentApplication,
													CholP);
					break;
/*				default: 							// Miscellaneous Holiday Flags
				         HolidayFlags ^= (1 << (itemNumber - 7));*/
			}
			RedrawCalendarWindow();
			break;

		case MONTH_MENU:
			// The item  number is the month to go to
			if (itemNumber != CurrentMonth) {
				CurrentMonth = itemNumber;
				RedrawCalendarWindow();
			}
			break;
			
		case YEAR_MENU:
			switch (itemNumber) {
				case 1:  CurrentYear++; RedrawCalendarWindow(); break;  // next year
				case 2:  CurrentYear--; RedrawCalendarWindow(); break;  // prev year
				case 3:  NewYearWindow(); break;						// goto year
			}
			break;
			
//		case EDIT_MENU:
//			// We don't do anything with these.
//			if (!SystemEdit(itemNumber - 1)) ;
//			break;
			
	}
	HiliteMenu(0);
}

/* Called just before pulling down a menu.  This highlights, dims, and checkmarks
 * each menu item as appropriate for the current circumstances.
 */
void
UpdateMenuSelection() 
{
	int i;
    SetItemMark(OptionMenu, 1, JulianP ? 0 : diamondMark);		// Gregorian
    SetItemMark(OptionMenu, 2, JulianP ? diamondMark : 0);		// Julian
    SetItemMark(OptionMenu, 4, IsraelP ? 0 : diamondMark);		// Diaspora
    SetItemMark(OptionMenu, 5, IsraelP ? diamondMark : 0);		// Israel
    /* We may add more flags later */
//    for (i = 0; i < 3; i++)
//        SetItemMark(OptionMenu, 7 + i, (HolidayFlags & (1 << i)) ? checkMark : 0);
	SetItemMark(OptionMenu, 7, ParshaP ? checkMark : 0);
	SetItemMark(OptionMenu, 8, OmerP ? checkMark : 0);
	SetItemMark(OptionMenu, 9, CholP ? checkMark : 0);
    for(i = 1; i <= 12; i++)
    	SetItemMark(MonthMenu, i, i == CurrentMonth ? diamondMark : 0);
    if (CurrentYear == MinYear) DisableMenuItem(YearMenu, 2); else EnableMenuItem(YearMenu, 2);
    if (CurrentYear == MaxYear) DisableMenuItem(YearMenu, 1); else EnableMenuItem(YearMenu, 1);

	// Can't re-enter printing
	if (printSession)
	{
		DisableMenuItem(FileMenu, 1);
		DisableMenuItem(FileMenu, 2);
	}
	else
	{
		EnableMenuItem(FileMenu, 1);
		EnableMenuItem(FileMenu, 2);
	}
}
    	


/* This filter for ModalDialog returns TRUE on any mouse or key event, even
 * if it is outside the dialog window.  Thus any key click or mouse event will 
 * make the dialog box disappear.
 */

#define kEmailButton 3
#define kWebButton 4

static void
AboutJewishCalendarWindow()
{
	ModalFilterUPP filterUPP = NewModalFilterUPP(EventFilter);
	Str255 versionString;
	DialogPtr aboutDialog;
	short itemHit = 0;
	short oldResFile;
	
	gInAboutDialog = TRUE;
	
	oldResFile = CurResFile();
	UseResFile(gAppResFile);
	GetVersNumString(versionString);
	UseResFile(oldResFile);
	
	ParamText(versionString, 0, 0, 0);
	aboutDialog = GetNewDialog(ABOUT_DIALOG, NULL, kFirstWindowOfClass);
	SetDialogDefaultItem(aboutDialog, 1);
	while (itemHit != 1)
		ModalDialog(filterUPP, &itemHit);
	DisposeDialog(aboutDialog);
	
	gInAboutDialog = FALSE;
	
	DisposeModalFilterUPP(filterUPP);
}

#define OK_BUTTON 1
#define CANCEL_BUTTON 2
#define STATIC_TEXT 3
#define EDIT_TEXT 4
#define NUDGE_WIDGET 5

#define UP_BUTTON 20
#define DOWN_BUTTON 21

/* Create a new year dialog.  Update CurrentYear, and redraw the calendar window if
 * necessary */
 
static void
NewYearWindow()
{
	ModalFilterUPP filterUPP = NewModalFilterUPP(EventFilter);
	ControlKeyFilterUPP numericFilterUPP = NewControlKeyFilterUPP(NumericFilter);
	
	DialogPtr modal;
	short itemHit;
	long int year;
	Boolean done, need_to_update;
	GrafPtr savePort;
	int OriginalCurrentYear = CurrentYear;		// Save initial value
	Size size;
	static ControlEditTextSelectionRec selectionRec = {0, 32767};
	
	gInYearDialog = TRUE;
	
	GetPort(&savePort);							// We're doing a lot of writing

	// Get the modal window, and set it to be our current grafport.
	modal = GetNewDialog(YEAR_DIALOG, NULL, kFirstWindowOfClass);
	SetPortDialogPort(modal);
	
	// Get a handle for the editable year.
	GetDialogItemAsControl(modal, EDIT_TEXT, &gEditBoxHandle);
	SetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextKeyFilterTag,
		sizeof(numericFilterUPP),(Ptr) &numericFilterUPP);
	
	GetDialogItemAsControl(modal, NUDGE_WIDGET, &gLittleArrows);
	SetControlMinimum(gLittleArrows, MinYear);
	SetControlMaximum(gLittleArrows, MaxYear);
	
	ShowWindow(GetDialogWindow(modal));
	SetDialogTracksCursor(modal, TRUE);
	SetDialogDefaultItem(modal, OK_BUTTON);
	SetDialogCancelItem(modal, CANCEL_BUTTON);
	done = FALSE;
	need_to_update = TRUE;
	while (!done) {
		Str255 buffer;
	    if (need_to_update) {
			// Fill in the current year as text, and highlight it.
			NumToString(CurrentYear, buffer);
			SetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextTextTag,
				buffer[0], &buffer[1]);
			SetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextSelectionTag,
				4 /*sizeof(selectionRec)*/, &selectionRec);
			need_to_update = FALSE;
		}
		
		ModalDialog(filterUPP, &itemHit);
		
		switch(itemHit)
		{
			case OK_BUTTON: 
				// Get the text.  See if it's a reasonable year.
				GetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextTextTag, 
					255, (Ptr)&buffer[1], &size);
				buffer[0] = size;
				StringToNum(buffer, &year);
				if ((year < MinYear) || (year > MaxYear)) // a bad year value
				{
					Str255 small;
					Str255 big;
					NumToString(MinYear, small);
					NumToString(MaxYear, big);
					ParamText(small, big, NULL, NULL);
					StopAlert(ILLEGAL_YEAR_ALERT, NULL);
					// Go back to the original year.
					CurrentYear = OriginalCurrentYear;
					need_to_update = TRUE;
				}
				else if (itemHit == OK_BUTTON) // all done.  And we have a reasonable year.
				{
					done = TRUE;
					CurrentYear = year;
				}
				break;
							
			case CANCEL_BUTTON:
				// abort all changes.  Go back to the original year.
				CurrentYear = OriginalCurrentYear;
				done = TRUE; 
				break;
			} /* of switch */
		} /* of while */
	// Restore the original grafport.  Update the calendar window if necessary
	
	SetPort(savePort);
	DisposeDialog(modal);
	if (CurrentYear != OriginalCurrentYear) 		
		RedrawCalendarWindow();
	
	gInYearDialog = FALSE;
	
	DisposeControlKeyFilterUPP(numericFilterUPP);
	DisposeModalFilterUPP(filterUPP);
}

pascal void
IncrementDecrementYear(ControlHandle controlHdl, short partCode)
{
	Str255 buffer;
	long year;
	static ControlEditTextSelectionRec selectionRec = {0, 32767};
	
	// get year
	year = GetControlValue(gLittleArrows);
	
	// inc/dec
	switch (partCode)
	{
		case kControlUpButtonPart:
			++year;
			if (year > MaxYear)
				year = MaxYear;
			break;
		
		case kControlDownButtonPart:
			--year;
			if (year < MinYear)
				year = MinYear;
			break;
		
		default:
			return; // no change; don't set
	}
	
	// set
	SetControlValue(gLittleArrows, year);
	NumToString(year, buffer);
	SetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextTextTag,
		buffer[0], &buffer[1]);
	SetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextSelectionTag,
		4 /*sizeof(selectionRec)*/, &selectionRec);
	
	DrawOneControl(gEditBoxHandle);
}

static pascal Boolean EventFilter(DialogPtr dialogPtr, EventRecord *theEvent, short *itemHit)
{
	Boolean handledEvent;
	GrafPtr oldPort;
	Point mouseXY;
	ControlHandle controlHdl;
	
	handledEvent = FALSE;

	if((theEvent -> what == updateEvt) && 
		 ((WindowPtr) (theEvent -> message) != GetDialogWindow(dialogPtr)))
	{
		UpdateEventCalendarWindow(theEvent);
	}
	else
	{
		GetPort(&oldPort);
		SetPortDialogPort(dialogPtr);

		if (gInYearDialog)
		{
			if (theEvent -> what == mouseDown)
			{
				mouseXY = theEvent -> where;
				GlobalToLocal(&mouseXY);
				if(FindControl(mouseXY, GetDialogWindow(dialogPtr), &controlHdl))
				{
					if(controlHdl == gLittleArrows)
					{
						Str255 buffer;
						Size size;
						long year;
						ControlActionUPP arrowsActionFunctionUPP;
						
						// set year
						GetControlData(gEditBoxHandle, kControlNoPart, kControlEditTextTextTag, 
							255, (Ptr)&buffer[1], &size);
						buffer[0] = size;
						StringToNum(buffer, &year);
						SetControlValue(gLittleArrows, year);
						
						arrowsActionFunctionUPP = NewControlActionUPP(IncrementDecrementYear);
						TrackControl(controlHdl, mouseXY, arrowsActionFunctionUPP);
						DisposeControlActionUPP(arrowsActionFunctionUPP);
						handledEvent = true;
					}
				}
			}
		}
		
		if (gInAboutDialog)
		{
			if (theEvent -> what == nullEvent && *itemHit == kEmailButton)
			{
                Str255 url;
				GetIndString(url, 128, 1);
                CFURLRef cfurl = CFURLCreateWithBytes(kCFAllocatorDefault,
                                                      url+1,
                                                      *url,
                                                      GetApplicationTextEncoding(),
                                                      NULL);
                LSOpenCFURLRef(cfurl, NULL);
                CFRelease(cfurl);
			}
			
			if (theEvent -> what == nullEvent && *itemHit == kWebButton)
			{
                Str255 url;
				GetIndString(url, 128, 2);
                CFURLRef cfurl = CFURLCreateWithBytes(kCFAllocatorDefault,
                                                      url+1,
                                                      *url,
                                                      GetApplicationTextEncoding(),
                                                      NULL);
                LSOpenCFURLRef(cfurl, NULL);
                CFRelease(cfurl);
			}
		}
		
		if (!handledEvent)
		{
			handledEvent = StdFilterProc(dialogPtr, theEvent, itemHit);
		}

		SetPort(oldPort);
	}

	return handledEvent;
}

pascal ControlKeyFilterResult NumericFilter(ControlHandle control, short* keyCode,
	short *charCode, unsigned short *modifiers)
{
	if(((char) *charCode >= '0') && ((char) *charCode <= '9'))
		return kControlKeyFilterPassKey;
	switch(*charCode)
	{
		case kLeftArrowCharCode:
		case kRightArrowCharCode:
		case kUpArrowCharCode:
		case kDownArrowCharCode:
		case kBackspaceCharCode:
			return kControlKeyFilterPassKey;
			break;
			
		default:
			SysBeep(20);
			return kControlKeyFilterBlockKey;
			break;
	}
}
