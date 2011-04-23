#include "Menu.h"
#include "Dialog.h"
#include "Holiday.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

void UpdateMenuSelection();


#define APPLE_MENU 128
#define FILE_MENU 129
#define EDIT_MENU 130
#define OPTION_MENU 131
#define MONTH_MENU 132
#define YEAR_MENU 133

#define MENU_BAR 128

#define ABOUT_DIALOG 128
#define YEAR_DIALOG 129
#define ILLEGAL_YEAR_ALERT 130

#define DOWN_PICTURE 128
#define SAME_PICTURE 129
#define UP_PICTURE   130

static void AboutJewishCalendarWindow(void);
static void NewYearWindow(void);

MenuHandle  DeskMenu, EditMenu, OptionMenu, MonthMenu, YearMenu;
PicHandle  	DownPicture, SamePicture, UpPicture;

/* Called at the beginning of the program to initialize the menu bar 
 */
 
void SetUpMenus()
{
    // Get the menu bar from the resource
    Handle myMenuBar = GetNewMBar(MENU_BAR);
    SetMenuBar(myMenuBar);
    // Get pointers to each of the menus.  We'll need them.
    DeskMenu = GetMHandle(APPLE_MENU);
    EditMenu = GetMHandle(EDIT_MENU);
    OptionMenu = GetMHandle(OPTION_MENU);
    MonthMenu = GetMHandle(MONTH_MENU);
    YearMenu = GetMHandle(YEAR_MENU);
    // Add the apple items.
    AddResMenu(DeskMenu, 'DRVR');
	DrawMenuBar();
	// Get pictures for the arrows in the year menu.
	DownPicture = GetPicture(DOWN_PICTURE); 
	SamePicture = GetPicture(SAME_PICTURE); 
	UpPicture = GetPicture(UP_PICTURE);
	HLock(DownPicture);
	HLock(SamePicture);
	HLock(UpPicture);
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
			else {
				// Do whatever is appropriate for the apple item 
				Str255		name;
				GrafPtr		port;
				GetPort(&port);
				GetItem(GetMHandle(APPLE_MENU), itemNumber, &name);
				OpenDeskAcc(name);
				SetPort(port);
			}
			break;
			
		case FILE_MENU:
			switch (itemNumber) {
				case 1:  PrintCalendar(); break;	// print
				case 3:  exit(EXIT_SUCCESS); break; // exit
			}
			break;
		
		case OPTION_MENU:
			switch (itemNumber) {
				case 1:  JulianP = FALSE; break;	// Gregorian
				case 2:	 JulianP = TRUE; break;		// Julian
				case 4:  IsraelP = FALSE; break;	// Diaspora
				case 5:  IsraelP = TRUE; break;		// Israel
				default: 							// Miscellaneous Holiday Flags
				         HolidayFlags ^= (1 << (itemNumber - 7));
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
			
		case EDIT_MENU:
			// We don't do anything with these.
			if (!SystemEdit(itemNumber - 1));
			break;
			
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
    for (i = 0; i < 3; i++)
        SetItemMark(OptionMenu, 7 + i, (HolidayFlags & (1 << i)) ? checkMark : 0);
    for(i = 1; i <= 12; i++)
    	SetItemMark(MonthMenu, i, i == CurrentMonth ? diamondMark : 0);
    if (CurrentYear == MinYear) DisableItem(YearMenu, 2); else EnableItem(YearMenu, 2);
    if (CurrentYear == MaxYear) DisableItem(YearMenu, 1); else EnableItem(YearMenu, 1);
}
    	


/* This filter for ModalDialog returns TRUE on any mouse or key event, even
 * if it is outside the dialog window.  Thus any key click or mouse event will 
 * make the dialog box disappear.
 */
 
pascal static Boolean 
       AboutFilter(DialogPtr theDialog, EventRecord *theEvent, int *itemhit);

static void
AboutJewishCalendarWindow()
{
	DialogPtr modal;
	short itemHit;
	ParamText("\p2.0", 0, 0, 0);
	modal = GetNewDialog(ABOUT_DIALOG, NULL, (WindowPtr)-1);
	/* AboutFilter makes it disappear on any keyclick or mouse event */
	ModalDialog(AboutFilter, &itemHit);
	CloseDialog(modal);
}

pascal static Boolean
AboutFilter(DialogPtr theDialog, EventRecord *theEvent, int *itemhit)
{
	switch (theEvent->what) {
		case mouseDown:	case mouseUp: case keyDown: case autoKey:
			*itemhit = 1;		/* Value doesn't really matter */
			 return TRUE;
		default:
			return FALSE;
	}
}

#define OK_BUTTON 1
#define CANCEL_BUTTON 2
#define STATIC_TEXT 3
#define EDIT_TEXT 4
#define USER_ITEM 5
#define PICTURE_ITEM 6

#define FAKE_UP_BUTTON 20
#define FAKE_DOWN_BUTTON 21

Rect UpBoxRectangle, DownBoxRectangle, PictureRectangle;
static int IncrementDecrementYear(Handle control, int year, Boolean up_p);
static pascal void userItemProc(WindowPtr wp, int ItemNum);
static pascal Boolean NewYearFilter(DialogPtr dp, EventRecord *theEvent, int *itemHit);


/* Create a new year dialog.  Update CurrentYear, and redraw the calendar window if
 * necessary */
 
static void
NewYearWindow()
{
	DialogPtr modal;
	short itemHit;
	int itemType;
	long int year;
	Rect itemRect;
	Handle EditItemHandle, PictureItemHandle;
	Boolean done, need_to_update;
	GrafPtr savePort;
	int picture_middle;
	int OriginalCurrentYear = CurrentYear;		// Save initial value

	GetPort(&savePort);							// We're doing a lot of writing

	// Get the modal window, and set it to be our current grafport.
	modal = GetNewDialog(YEAR_DIALOG, NULL, (WindowPtr)-1);
	SetPort((WindowPtr) modal);

	// Get the dimension of the picture item.  Set its top half to be the "move up"
	// region, and its bottom half to be the "move down" regin.
	GetDItem(modal, PICTURE_ITEM, &itemType, &PictureItemHandle, &PictureRectangle);
	picture_middle = (PictureRectangle.top + PictureRectangle.bottom)/2;
	SetRect(&UpBoxRectangle, 
			PictureRectangle.left,  PictureRectangle.top,
			PictureRectangle.right, picture_middle);
	SetRect(&DownBoxRectangle, 
			PictureRectangle.left,  picture_middle,
			PictureRectangle.right, PictureRectangle.bottom);

	// Get a handle for the editable year.  And give USER_ITEM a write procedure */
	GetDItem(modal, EDIT_TEXT, &itemType, &EditItemHandle, &itemRect);
	SetDItem(modal, USER_ITEM, userItem, (Handle)userItemProc, &itemRect);

	ShowWindow(modal);
	for (done=FALSE, need_to_update = TRUE;  !done; ) {
		char buffer[256];
	    if (need_to_update) {
			// Fill in the current year as text, and highlight it.
			char year_string[10];
	    	year_string[0] = sprintf(year_string + 1, "%d", CurrentYear);
			SetIText(EditItemHandle, year_string);
			SelIText(modal, EDIT_TEXT, 0, 32767);
			need_to_update = FALSE;
		}
		ModalDialog(NewYearFilter, &itemHit);
		switch(itemHit) {
			case OK_BUTTON: 
			case FAKE_UP_BUTTON:
			case FAKE_DOWN_BUTTON:
				// Get the text.  See if it's a reasonable year.
				GetIText(EditItemHandle, buffer);
				PtoCstr(buffer);
				year = atol(buffer);
				if ((year < MinYear) || (year > MaxYear)) {
					// a bad year value
					char small[10], big[10];
					small[0] = sprintf(small+1, "%d", MinYear);
					big[0] = sprintf(big+1, "%d", MaxYear);
					ParamText(small, big, 0, 0);
					StopAlert(ILLEGAL_YEAR_ALERT, NULL);
					// Go back to the original year.
					CurrentYear = OriginalCurrentYear;
					need_to_update = TRUE;
				} else if (itemHit == OK_BUTTON) {
					// all done.  And we have a reasonable year.
					done = TRUE;
					CurrentYear = year;
				} else {
					// In the "year up" or year down" region.
					Boolean up_p = (itemHit == FAKE_UP_BUTTON);
					CurrentYear = IncrementDecrementYear(EditItemHandle, year, up_p);
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
	CloseDialog(modal);
	if (CurrentYear != OriginalCurrentYear) 		
		RedrawCalendarWindow();
}

/* The filter for the New Year window.  We don't allow most non-digits.  Clicks in the
 * picture region get interpreted as either clicks to move the window up, or clicks
 * to move the window down.
 */
static pascal Boolean 
NewYearFilter(DialogPtr dp, EventRecord *theEvent, int *itemHit){
	char theChar;
	Point EventPoint;
	GrafPtr savePort;
	
	switch (theEvent->what) {
		case keyDown: case autoKey:
			theChar = theEvent->message & charCodeMask;
			switch(theChar) {
				case '\r': case '\003': 	/* return, enter */  
					*itemHit = 1; return TRUE;
				case '\b': case '\34': case '\35':  /* backspace, arrows */             
				case '0': case '1': case '2': case '3': case '4':
				case '5': case '6': case '7': case '8': case '9':
					return FALSE;
				default:
					// ignore everything else
					SysBeep(0);				// beep at user
					theEvent->what = nullEvent;
					return FALSE;
			}
			
		case mouseDown:
			EventPoint = theEvent->where;
			GlobalToLocal(&EventPoint);
			if (PtInRect(EventPoint, &UpBoxRectangle)) {
				// user wants to move the year upward
				*itemHit = FAKE_UP_BUTTON;
				return TRUE;
			} else if (PtInRect(EventPoint, &DownBoxRectangle)) {
				// user wants to move the year downward.
				*itemHit = FAKE_DOWN_BUTTON;
				return TRUE;
			} else
				return FALSE;
		default:
			return FALSE;
	}
}

/* We hilight the okay button by creating a user proc for the user_item.  It gets
 * moved to the exact same location as the OK button, but inside
 */
 
static pascal void 
userItemProc(WindowPtr wp, int ItemNum){
	int itemType;
	Handle itemHandle;
	Rect itemRect;
		
	GetDItem(wp, OK_BUTTON, &itemType, &itemHandle, &itemRect);
	PenSize(3, 3);
	InsetRect(&itemRect, -4, -4);
	FrameRoundRect(&itemRect, 16, 16);
}


/* Called when the user has clicked down in the "year up" or "year down" region.
 * delta will either be +1 or -1.  year is the current year in the window.  Returns 
 * the new year as its result.
 */
static int
IncrementDecrementYear(Handle EditItemHandle, int year, Boolean up_p)
{
	long int junk;
	char year_string[10];
	int count;
	Point point;
	int delta = up_p ? 1 : -1;

	// Change the picture in the window to either be an up arrow or down arrow.
	DrawPicture(up_p ? UpPicture : DownPicture, &PictureRectangle);
	// Change the year by delta, if legal.
	if (up_p ? (year < MaxYear) : (year > MinYear)) year += delta;
	for (count = 0; ; count++) {
		// Times 0-9 through the loop are special.  We don't modify the year, but
		// we look to see if the user has let up on the mouse or moved it.  This gives
		// us a pause of about 1/2 second.	
	   	if ((count == 0) || (count >= 10)) {
	   		year_string[0] = sprintf(year_string + 1, "%d", year);
			SetIText(EditItemHandle, year_string);
		}
		// Wait.  1/20 second.
		Delay(60/20, &junk);
		if (StillDown() && (GetMouse(&point), PtInRect(point, &PictureRectangle))) {
			// the mouse button is still down, and the mouse hasn't moved.
			if ((count >= 10) && (up_p ? (year < MaxYear) : (year > MinYear)))
				 year += delta;
		} else
			break;
	}
	// Change the picture back to its old value/
	DrawPicture(SamePicture, &PictureRectangle);
	return year;
}
