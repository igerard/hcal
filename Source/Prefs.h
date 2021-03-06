#pragma once

#define kJulianCalendarPrefRef	CFSTR("JulianCalendar")
#define kIsraelPrefRef			CFSTR("Israel")

#define kParshaPrefRef			CFSTR("Parsha")
#define kOmerPrefRef			CFSTR("Omer")
#define kCholHamoedPrefRef		CFSTR("CholHamoed")

#define kPageSetupPrefRef		CFSTR("PageSetup")

void CFPreferencesSetAppBooleanValue(
		  CFStringRef	key,
		  CFStringRef	applicationID,
		  Boolean		value);
