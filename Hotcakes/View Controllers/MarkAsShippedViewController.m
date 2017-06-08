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

#import "MarkAsShippedViewController.h"

@implementation MarkAsShippedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GoogleAnalytics trackScreenViewWithName:@"Shipping Information"];
    
    self.pickerTitle = @"Select a Shipper";
    
    void (^generalError) ()   = ^(NSError *generalError){
        [self.activityView stopAnimating];
        
        NSString *message   = [NSString stringWithString:generalError.localizedDescription];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^error) ()    = ^{
        [self.activityView stopAnimating];

        NSString *message   = [NSString stringWithFormat:@"Invalid username or password"];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Login Failure"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^status) ()   = ^(int code){
        [self.activityView stopAnimating];

        NSString *message   = [NSString stringWithString:[NSString stringWithFormat:@"An error occurred processing the request: %d", code]];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^callback) () = ^(NSArray *shippersAvailable)
    {
        self.choiceObjects = [shippersAvailable mutableCopy];
        self.choices = [@[] mutableCopy];
        for (Shipper * shipper in shippersAvailable)
            [self.choices addObject:shipper.name];
        
        [self updateUI];
    };

    [self.api getShippersById:self.order.orderId withCallback:callback authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status];
}

- (void)performAction
{
    [super performAction];
    
    [GoogleAnalytics trackUXTouchWithName:@"Mark As Shipped" value:nil];
    
    void (^generalError) ()   = ^(NSError *generalError){
        [self.activityView stopAnimating];
        
        NSString *message   = [NSString stringWithString:generalError.localizedDescription];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^error) ()    = ^{
        [self.activityView stopAnimating];
        
        NSString *message   = [NSString stringWithFormat:@"Invalid username or password"];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Login Failure"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^status) ()   = ^(int code){
        [self.activityView stopAnimating];
        
        NSString *message   = [NSString stringWithString:[NSString stringWithFormat:@"An error occurred processing the request: %d", code]];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };

    [self.api markOrder:self.order.orderId
     asShippedByShipper:((Shipper *)self.choiceObjects[self.selection]).code
     withTrackingNumber:self.valueTextField.text
           successBlock: ^{
               [self popWithOrder];
           } authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status
    ];
}

- (void)updateUI
{
    [super updateUI];
    NSString *inst = self.order.specialInstructions;
    self.specialInstructions.text = inst;
}

@end
