#include <stdio.h>
#include <stdlib.h>
#include "Dialog.h"
#include "Menu.h"
/* #include <profile.h> */


static void DoMouseDownStuff(EventRecord *theEvent);
static void restartProc(void);

/* If there are any errors in dialog windows, just exit */
static void
restartProc()
{
	exit(1);
}


main()
{
	EventRecord		theEvent;
	DialogPtr		whichDialog;
	short			whichItem, windowcode, type;
	WindowPtr		whichWindow;
	int				theChar;
	long			menuEvent;
	
	
	// Initialize the world.
 	InitGraf(&thePort);
	InitFonts();
	InitWindows();
	InitMenus(); 
	InitDialogs(restartProc);
	InitCursor();
	InitializeDialogWindow();
	SetUpMenus();						// get the initial menus.
	FlushEvents(everyEvent, 0);			// throw away any events already queued
	while(1) {
		InitCursor();
		SystemTask();
		if (GetNextEvent(everyEvent, &theEvent)) {
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
				case activateEvt:
					// Currently, we don't deal with this.
					// if (theEvent.modifiers & activeFlag) {} else {}
					break;
			}
		}
	}
}
				

/* Handle a mouse down event */

static void
DoMouseDownStuff(EventRecord *theEvent)
{
	Rect		tempRect;
	WindowPtr	whichWindow;
	short		windowcode, partcode;
	Point		EventPoint;
	ControlHandle whichControl;
	
	windowcode = FindWindow(theEvent->where, &whichWindow);
	switch(windowcode) {
		case inSysWindow:
			// Do whatever the system wants to do with it.
			SystemClick(theEvent, whichWindow);
			break;
						
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
				if (partcode = FindControl(EventPoint, whichWindow, &whichControl)) 
					HandleControlItem (EventPoint, partcode, whichControl);
				}
			break;
			
		case inDrag:
			// Drag the window.
			SetRect(&tempRect,
					screenBits.bounds.left+4, screenBits.bounds.top+24,
					screenBits.bounds.right-4, screenBits.bounds.bottom-4);
			DragWindow(whichWindow, theEvent->where, &tempRect);
			break;
			
		case inGoAway:
			// Just kill the program when we're supposed to go away.
			if (TrackGoAway(whichWindow, theEvent->where))
				exit(EXIT_SUCCESS);
			break;
	}
}
