#include "Prefs.h"

void CFPreferencesSetAppboolValue(
			CFStringRef	key,
			CFStringRef	applicationID,
			bool		value)
{
	if (value)
		CFPreferencesSetAppValue(key, kCFboolTrue, applicationID);
	else
		CFPreferencesSetAppValue(key, kCFboolFalse, applicationID);
	CFPreferencesAppSynchronize(applicationID);
}
