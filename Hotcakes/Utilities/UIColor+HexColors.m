/*
   Hotcakes Commerce - https://hotcakes.org
   Copyright (c) 2017
   by Hotcakes Commerce, LLC
   
   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
   documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
   the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
   to permit persons to whom the Software is furnished to do so, subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in all copies or substantial portions 
   of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
   TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
   CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
   DEALINGS IN THE SOFTWARE.
*/

#import "UIColor+HexColors.h"

@implementation UIColor (HexColors)

+ (UIColor*)colorWithHexValue:(uint)hexValue
{
    return [self colorWithHexValue:hexValue andAlpha:1.0];
}

+ (UIColor*)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha
{
    return [UIColor
            colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
            green:((float)((hexValue & 0xFF00) >> 8))/255.0
            blue:((float)(hexValue & 0xFF))/255.0
            alpha:alpha];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString
{
    return [self colorWithHexString:hexString andAlpha:1.0];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString andAlpha:(float)alpha
{
    UIColor *col;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#"
                                                     withString:@"0x"];
    uint hexValue;
    if ([[NSScanner scannerWithString:hexString] scanHexInt:&hexValue])
        col = [self colorWithHexValue:hexValue andAlpha:alpha];
     else // invalid hex string
        col = [self blackColor];
    
    return col;
}

@end
