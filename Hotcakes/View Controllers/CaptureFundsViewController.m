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

#import "CaptureFundsViewController.h"
#import "NSNumberFormatterFactory.h"

#define kFundsTextField 1

@implementation CaptureFundsViewController  { }


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [GoogleAnalytics trackScreenViewWithName:@"Funds Information"];
    
    self.pickerTitle = @"Select a Card";
    
    if (!self.order.isPaid)
    {
        self.choiceObjects = self.order.pendingHolds;
        self.choices = [@[] mutableCopy];
        for (HoldTransaction *transaction in self.order.pendingHolds)
            [self.choices addObject:(NSString*)transaction.cardInfo];
    }

	[self updateUI];
}


#pragma mark - UI State

- (void)updateUI
{
    [super updateUI];

    NSNumberFormatter *decimalFormatter = NSNumberFormatterFactory.localizedDecimalFormatter;

    if ([self.order.paymentAmountDue floatValue] >0)
    {
        self.valueTextField.text = [decimalFormatter stringFromNumber:self.order.paymentAmountDue];
    }
    else
    {
        self.valueTextField.text = @"0";
    }
    
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;

                                    self.reservedLabel.text = [formatter stringFromNumber:self.order.paymentAmountAuthorized];
    self.receivedLabel.text = [formatter stringFromNumber:self.order.paymentAmountCharged];
    self.refundedLabel.text = [formatter stringFromNumber:self.order.paymentAmountRefunded];
    self.amountDueLabel.text = [formatter stringFromNumber:self.order.paymentAmountDue];
}

#pragma mark - Action

- (BOOL)validate
{
    if(![super validate])
        return NO;
    
    float value = self.valueTextField.text.floatValue;
    if (value > self.order.total.floatValue)
    {
        [[[UIAlertView alloc] initWithTitle:@"Validation Error"
                                    message:@"Can't capture a payment larger than the amount due."
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil]
         show];
        return  NO;
    }
    else if (value == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Validation Error"
                                    message:@"Value must be greated than 0."
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil]
         show];
        return  NO;
    }
    
    return YES;
}

- (void)performAction
{
    [super performAction];
    
    [GoogleAnalytics trackUXTouchWithName:@"Capture Funds" value:nil];
    
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
    asPaidByTransaction:((HoldTransaction *)self.choiceObjects[self.selection]).transactionId
             withAmount:self.valueTextField.text
           successBlock:^{
               [self popWithOrder];
           }
            authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status
     ];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField //resign first responder for textfield
{
    [textField resignFirstResponder];
    return YES;
}

// only allow numbers, the correct decimal separator, and the correct number
// of digits after the decimal separator
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] < 1)    // non-visible characters are okay
        return YES;
    
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;
    
    NSMutableCharacterSet *currencySet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [currencySet addCharactersInString:[formatter.locale objectForKey:NSLocaleDecimalSeparator]];
    
    NSString *symbol = [formatter.locale objectForKey:NSLocaleDecimalSeparator];
    if (range.location == 0 && [string isEqualToString:symbol]) {
        // decimalseparator should not be first
        return NO;
    }
    
    NSRange separatorRange = [textField.text rangeOfString:symbol];
    
    if (separatorRange.location != NSNotFound) {
        // allow the correct number of digits after the decimal separator
        if (range.location > (separatorRange.location + formatter.maximumFractionDigits)) {
            return NO;
        }
        else
        {
            // only allow digits to be after the decimal separator
            if (range.location > separatorRange.location)
            {
                if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound)
                {
                    return NO;
                }
            }
        }
    }
    
    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]].length == 0)
        return YES;
    
    return ([string stringByTrimmingCharactersInSet:[currencySet invertedSet]].length > 0);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField.tag == kFundsTextField){
        return YES;
    }
    else{
        return NO;
    }
}

@end
