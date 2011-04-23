#include <stdio.h>
#include <stdlib.h>
#include "Dialog.h"
#include "Menu.h"
#include "Prefs.h"
#include "Holiday.h"

#define MAINFILE
#include "Globals.h"
#undef MAINFILE

static void DoMouseDownStuff(EventRecord *theEvent);
static void InitPrefs();
static pascal OSErr QuitHandler (const AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon);

void main(void)
{
	EventRecord		theEvent;
	int				theChar;
	AEEventHandlerUPP quitHandler = NewAEEventHandlerUPP(QuitHandler);
	
	// Initialize the world.
	gAppResFile = CurResFile();
	gAreWeDoneYet = false;
	InitCursor();
	InitPrefs();
	InitializeDialogWindow();
	SetUpMenus();						// get the initial menus.
	FlushEvents(everyEvent, 0);			// throw away any events already queued
	AEInstallEventHandler(kCoreEventClass, kAEQuitApplication, quitHandler, 0, false);
	
	while(!gAreWeDoneYet) {
		if (WaitNextEvent(everyEvent, &theEvent, GetCaretTime(), nil)) {
			switch (theEvent.what) {
				case mouseDown:
					// Do whatever we're supposed to do with this mouse event.
					DoMouseDownStuff(&theEvent);
					break;
					
				case updateEvt:
					// Update the screen as appropriate.
					UpdateEventCalendarWindow(&theEvent);
					break;
					
				case keyDown:
				case autoKey:
					// The only key events we handle are command keys
					theChar = theEvent.message & charCodeMask;
					if (theEvent.modifiers & cmdKey) 
						doMenu(MenuKey(theChar));
					break;
				
				case kHighLevelEvent:
					AEProcessAppleEvent(&theEvent);
			}
		}
	}
}

/* Handle a mouse down event */

static void
DoMouseDownStuff(EventRecord *theEvent)
{
	WindowPtr	whichWindow;
	short		windowcode, partcode;
	Point		EventPoint;
	ControlHandle whichControl;
	
	windowcode = FindWindow(theEvent->where, &whichWindow);
	switch(windowcode) {
		case inMenuBar:
			// Go handle a menu selection
			UpdateMenuSelection();
			doMenu(MenuSelect(theEvent->where));
			break;
		
		case inContent:
			if (whichWindow != FrontWindow())
				// Bring the window to the front, if it isn't.
				SelectWindow(whichWindow);
			else {
				// If the click is in a control, deal with it.
				EventPoint = theEvent->where;
				GlobalToLocal(&EventPoint);
				if ((partcode = FindControl(EventPoint, whichWindow, &whichControl))) 
					HandleControlItem (EventPoint, partcode, whichControl);
				}
			break;
			
		case inDrag:
			// Drag the window.
			DragWindow(whichWindow, theEvent->where, nil);
			break;
			
		case inGoAway:
			// Just kill the program when we're supposed to go away.
			if (TrackGoAway(whichWindow, theEvent->where))
				gAreWeDoneYet = true;
			break;
	}
}

void InitPrefs()
{
	Boolean isValid;
	
	JulianP = CFPreferencesGetAppBooleanValue(kJulianCalendarPrefRef, kCFPreferencesCurrentApplication,
												&isValid);
	IsraelP = CFPreferencesGetAppBooleanValue(kIsraelPrefRef, kCFPreferencesCurrentApplication,
												&isValid);
	
	ParshaP = CFPreferencesGetAppBooleanValue(kParshaPrefRef, kCFPreferencesCurrentApplication,
												&isValid);
	if (!isValid)
		ParshaP = true;
	
	OmerP = CFPreferencesGetAppBooleanValue(kOmerPrefRef, kCFPreferencesCurrentApplication,
												&isValid);
	if (!isValid)
		OmerP = true;
	
	CholP = CFPreferencesGetAppBooleanValue(kCholHamoedPrefRef, kCFPreferencesCurrentApplication,
												&isValid);
	if (!isValid)
		CholP = true;
}

pascal OSErr QuitHandler (const AppleEvent */*theAppleEvent*/, AppleEvent *reply, long /*handlerRefcon*/)
{
	if (reply && reply -> dataHandle != NULL )	/*	a reply is sought */
		AEPutParamPtr(reply, 'errs', 'TEXT', "Sayonara", 8);
	
	gAreWeDoneYet = true;
	
	return noErr;
}
