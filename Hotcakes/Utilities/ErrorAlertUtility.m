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

#import "ErrorAlertUtility.h"

@implementation ErrorAlertUtility

+ (void)showUnreachableConnectionError
{
    NSString *message = [NSString stringWithFormat:@"We couldn't reach your site. Make sure you're connected to the internet and verify your site is set up properly"];
    
    [self showUnreachableError:message];
}

+ (void)showUnreachableConnectionErrorForURL:(NSString *)baseURL
{
    NSURL *url = [NSURL URLWithString:baseURL];
    NSString *message = [NSString stringWithFormat:@"We couldn't reach your site (%@). Make sure you're connected to the internet and verify your site is set up properly", url.host];

    [self showUnreachableError:message];
}

+ (void)showUnreachableError:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Site unreachable"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    //[alert show];
    
    // Make sure it's called on main thread for UI stuff instead of background
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

@end
