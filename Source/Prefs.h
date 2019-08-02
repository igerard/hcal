#pragma once

#include <Carbon/Carbon.h>

#define kJulianCalendarPrefRef	CFSTR("JulianCalendar")
#define kIsraelPrefRef			CFSTR("Israel")

#define kParshaPrefRef			CFSTR("Parsha")
#define kOmerPrefRef			CFSTR("Omer")
#define kCholHamoedPrefRef		CFSTR("CholHamoed")

#define kPageSetupPrefRef		CFSTR("PageSetup")

void CFPreferencesSetAppboolValue(
		  CFStringRef	key,
		  CFStringRef	applicationID,
		  bool		value);
