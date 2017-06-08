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

#import "LoginViewController.h"
#import "DesignUtility.h"
#import "UIView+AnimatedSlide.h"
#import "UIActivityIndicatorView+MaskView.h"
#import "IXKeychain.h"
#import "GoogleAnalytics.h"
#import "Utilities.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.versionNumber.text = [NSString stringWithFormat:@"v%@", [Utilities getVersionNumber]];
    
    [GoogleAnalytics trackScreenViewWithName:@"Login"];
    
    [DesignUtility modifyTextField:self.siteTextField];
    [DesignUtility modifyTextField:self.usernameTextField];
    [DesignUtility modifyTextField:self.passwordTextField];
    
    api = HotcakesApi.instance;

    activityView = [UIActivityIndicatorView maskedUIActivityIndicatorWithView:self.view];
    
    NSString *site = [Keychain secureValueForKey:@"site"];
    NSString *username = [Keychain secureValueForKey:@"username"];
    NSString *password = [Keychain secureValueForKey:@"password"];
    if (site != nil) {
        self.siteTextField.text=site;
    }

    if (username != nil) {
        self.usernameTextField.text=username;
    }

    if (password != nil) {
        self.passwordTextField.text=password;
    }
}

- (IBAction)loginButtonClicked:(id)sender
{
    [GoogleAnalytics trackUXTouchWithName:@"Login Button" value:nil];
    
    [activityView startAnimating];
    
    
    NSString *site      = self.siteTextField.text;
    NSString *username  = self.usernameTextField.text;
    NSString *password  = self.passwordTextField.text;
    
    void (^storecallback) () = ^(StoreSettings *settings){
    
        [Keychain setSecureValue:settings.currencyCultureCode forKey:@"currencyculturecode"];
        
        [activityView stopAnimating];
        [self performSegueWithIdentifier:@"DashboardSegue" sender:self];
    };
    
    void (^generalError) ()   = ^(NSError *generalError){
        [activityView stopAnimating];
        
        NSString *message   = [NSString stringWithString:generalError.localizedDescription];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^success) ()  = ^{
        
        [api getStoreSettingsWithCallback:storecallback generalErrorBlock:generalError];
    };
    
    void (^error) ()    = ^{
        [activityView stopAnimating];
        
        NSString *message   = [NSString stringWithFormat:@"Invalid username or password"];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Login Failure"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    void (^status) ()   = ^(int code){
        [activityView stopAnimating];
        
        NSString *message   = [NSString stringWithString:[NSString stringWithFormat:@"An error occurred processing the request: %d", code]];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    [api loginWithSite:site username:username password:password completionBlock:success authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status];
}

// Allow closing of keyboard when clicking on the background
- (IBAction)backgroundClicked:(id)sender
{
    [self.siteTextField     resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

// Scroll view while editing text fields
// Reference: http://stackoverflow.com/questions/1247113/
- (IBAction)textFieldEditingDidBegin:(UITextField *)sender
{
    [DesignUtility modifyTextFieldActive:sender];
    [self.view animateViewUp:YES distance:200 duration:0.3f];
}

- (IBAction)textFieldEditingDidEnd:(UITextField *)sender
{
    if (sender == self.siteTextField) {
        [Keychain setSecureValue:sender.text forKey:@"site"];
    }
    else if (sender == self.usernameTextField) {
        [Keychain setSecureValue:sender.text forKey:@"username"];
    }
    else if (sender == self.passwordTextField) {
        [Keychain setSecureValue:sender.text forKey:@"password"];
    }
    
    [DesignUtility modifyTextField:sender];
    [self.view animateViewUp:NO distance:200 duration:0.3f];
}

@end
