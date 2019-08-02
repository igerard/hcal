#pragma once

void InitializeDialogWindow(void);
void UpdateEventCalendarWindow(EventRecord *theEvent);
void HandleControlItem (Point EventPoint, short partcode, ControlHandle whichControl);
void PageSetup(void);
void PrintCalendar(void);
void RedrawCalendarWindow(void);
extern int CurrentMonth, CurrentYear;
extern int MinYear, MaxYear;
extern bool JulianP;
extern bool IsraelP;
extern PMPrintSession printSession;
