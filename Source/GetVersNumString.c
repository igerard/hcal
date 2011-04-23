#include "GetVersNumString.h"

/* GetVersNumString
 * Reads 'vers' resource #1 and constructs a string like "\p1.0d3"...
 * If it can't find 'vers' #1, it returns an empty string.
 * NOTE: The application resource file must be the active resource file!
 */
void GetVersNumString(Str255 versStr)
{
    // clear string
    versStr[0]=0;
    
    // get value
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFTypeRef value = CFBundleGetValueForInfoDictionaryKey(mainBundle, kCFBundleVersionKey);
    if (CFGetTypeID(value) != CFStringGetTypeID())
        return;
    
    // convert
    (void)CFStringGetPascalString((CFStringRef)value,
                                  versStr,
                                  255,
                                  GetApplicationTextEncoding());
    
    return;
}
