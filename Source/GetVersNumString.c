#include "GetVersNumString.h"

void PStringCopy(Str255 a, Str255 b);
void PStringCat(Str255 a, Str255 b);

/* GetVersNumString
 * Reads 'vers' resource #1 and constructs a string like "\p1.0d3"...
 * If it can't find 'vers' #1, it returns an empty string.
 * NOTE: The application resource file must be the active resource file!
 */
void GetVersNumString(Str255 versStr)
{
 Handle  versHdl;
 long    version;
 unsigned char   ver1,ver2,ver3,relStatus,prerelNum;
 Str255  tmp;

    // clear string;
 versStr[0]=0;

    // read version no. information
 versHdl = GetResource('vers',1);
 if (!versHdl) {
 return;
 }
 version = *((long *)(*versHdl));
 ReleaseResource(versHdl);

    // Set ver1-3, relStatus, prerelNum from the version info.
    // Note that the first two bytes are in an unusual format.
 ver1 = ((char *)&version)[0];
 ver1 = (((ver1 & 0xF0) >> 4) * 10) + (ver1 & 0x0F);
 ver2 = (((char *)&version)[1] & 0xF0) >> 4;
 ver3 = (((char *)&version)[1] & 0x0F);
 relStatus = ((char *)&version)[2];
 prerelNum = ((char *)&version)[3];

    // Insert v1 and v2 into our version string.
 NumToString((long)ver1,tmp);
 PStringCat(versStr,tmp);
 PStringCat(versStr,"\p.");
 NumToString((long)ver2,tmp);
 PStringCat(versStr,tmp);
    // For convenience, we only print the third number if it is  non-zero.
    // If you always want all three numbers, remove the if-statement.
 if (ver3) {
 PStringCat(versStr,"\p.");
 NumToString((long)ver3,tmp);
 PStringCat(versStr,tmp);
 }

    // If the release status is development, alpha, or beta, add a
    // 'd', 'a', or 'b' to our version string.
 switch(relStatus){
 case 0x20: // development
 PStringCat(versStr,"\pd");
 break;
 case 0x40: // alpha
 PStringCat(versStr,"\pa");
 break;
 case 0x60: // beta
 PStringCat(versStr,"\pb");
 break;
 default:
 ;
 }

    // lastly, if we've added a 'd', 'a', or 'b', print the pre-release
    // number at the end.
 if (relStatus != 0x80) {
 NumToString((long)prerelNum,tmp);
 PStringCat(versStr,tmp);
 }
}

/* PStringCopy
 * Copy pascal string a into b.
 */

void PStringCopy(Str255 a, Str255 b)
{
 BlockMove(a,b, a[0] + 1);
}

/* PStringCat
 * Concatenate pascal strings a &amp; b, return in a. If there isn't enough
 * room in our array to join both strings, return what we can.
 */

void PStringCat(Str255 a, Str255 b)
{
 short len;

 if ((a[0] + b[0]) > 255)
 len = 255-a[0];
 else
 len = b[0];

 BlockMove(&(b[1]),&(a[a[0]+1]),len);
 a[0] += len;
}

