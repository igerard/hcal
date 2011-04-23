#include "Prefs.h"

void CFPreferencesSetAppBooleanValue(
			CFStringRef	key,
			CFStringRef	applicationID,
			Boolean		value)
{
	if (value)
		CFPreferencesSetAppValue(key, kCFBooleanTrue, applicationID);
	else
		CFPreferencesSetAppValue(key, kCFBooleanFalse, applicationID);
	CFPreferencesAppSynchronize(applicationID);
}
