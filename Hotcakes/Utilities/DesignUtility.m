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

#import "DesignUtility.h"
#import "UIColor+HexColors.h"
#import <QuartzCore/QuartzCore.h>

@implementation DesignUtility

+ (void) modifyTextField:(UITextField *)textField
{
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 20)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.layer.borderColor = [[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] CGColor];
    textField.layer.borderWidth = 1.0;
        textField.clipsToBounds = YES;
}


+ (void) modifyTextFieldActive:(UITextField *)textField
{
    textField.layer.borderColor = [[UIColor colorWithRed:249/255.0f green:76/255.0f blue:43/255.0f alpha:1] CGColor];
    textField.layer.borderWidth = 1.0;
    textField.clipsToBounds = NO;
    textField.layer.shadowColor = [[UIColor colorWithRed:249/255.0f green:76/255.0f blue:43/255.0f alpha:1] CGColor];
    textField.layer.shadowRadius = 2.5;
    textField.layer.shadowOffset = CGSizeMake(0, 0);
    textField.layer.shadowOpacity = 1.0;
}

+ (void) modifyLabel:(UILabel *)label
{
    [self modifyLabel:label withSize:18];
}

+ (void) modifyLabel:(UILabel *)label withSize:(CGFloat)size
{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    label.textColor = self.accentColor;
    label.shadowColor = self.accentShadowColor;
    label.backgroundColor = [UIColor clearColor];
}

/*
+ (void) colors
{
    UIColor *primary = [UIColor colorWithHexValue:0xf94c2b];
    UIColor *secondary = [UIColor colorWithHexValue:0x797c7c];
    UIColor *tertiary = [UIColor colorWithHexValue:0x292929];
    UIColor *accent = [UIColor colorWithHexValue:0xfff1ce];

    UIColor *background = [UIColor colorWithHexValue:0xf1f1f1];
    UIColor *alternateBackground = [UIColor colorWithHexValue:0xe4eaeb];
    UIColor *stroke = [UIColor colorWithHexValue:0xcccccc];
    
    UIColor *shadow = [UIColor colorWithHexValue:0xffffff];
    UIColor *accentShadow = [UIColor colorWithHexValue:0xe10000];
}
*/

+ (UIColor *) primaryColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xf94c2b];
    return color;
}

+ (UIColor *) secondaryColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0x797c7c];
    return color;
}

+ (UIColor *) tertiaryColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0x292929];
    return color;
}

+ (UIColor *) accentColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xfff1ce];
    return color;
}

+ (UIColor *) backgroundColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xf1f1f1];
    return color;
}

+ (UIColor *) alternateBackgroundColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xe4eaeb];
    return color;
}


+ (UIColor *) strokeColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xcccccc];
    return color;
}

+ (UIColor *) shadowColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xffffff];
    return color;
}

+ (UIColor *) accentShadowColor
{
    static UIColor *color = nil;
    if (color == nil)
        color = [UIColor colorWithHexValue:0xe10000];
    return color;
}


@end
