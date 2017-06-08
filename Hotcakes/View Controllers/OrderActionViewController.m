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

#import "OrderActionViewController.h"
#import "DesignUtility.h"
#import "NSNumberFormatterFactory.h"
#import "ActionSheetPicker.h"
#import "NSArray+NegativeIndexAccessor.h"
#import "UIView+AnimatedSlide.h"
#import "ErrorAlertUtility.h"
#import "UIActivityIndicatorView+MaskView.h"

@implementation OrderActionViewController { }

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.api = [HotcakesApi instance];

    [DesignUtility modifyTextField:self.selectionTextField];
    [DesignUtility modifyTextField:self.valueTextField];
    // Call API and updateUI in subclass
    
    self.invalidActionLabel.hidden=YES;
    self.actionView.hidden=YES;
    
    self.activityView = [UIActivityIndicatorView maskedUIActivityIndicatorWithView:self.view];
    [self.activityView startAnimating];
}

#pragma mark - UI State

- (void)updateUI
{
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;
   
    // Handle Invalid Action
    if (self.choices.count == 0)
    {
        self.invalidActionLabel.hidden = NO;
    }
    else
    {
        self.actionView.hidden = NO;
    }
    
    self.customerLabel.text = self.order.customerName;
    self.orderIdLabel.text = [NSString stringWithFormat:@"Order # %@", self.order.orderNumber];
    self.totalLabel.text = [formatter stringFromNumber:self.order.total];
    
    // Set Default UI Values
    if (self.choices.count == 1)
    {
        self.selectionTextField.text = self.choices[0];
        self.selection = 0;
    }
    
    [self.activityView stopAnimating];
}

- (void)popWithOrder
{
    [self.activityView stopAnimating];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshData" object:self];

    UIViewController *previousViewController = [[self.navigationController viewControllers] objectFromEnd:1];
    if ([previousViewController respondsToSelector:@selector(setOrder:)])
        [previousViewController performSelector:@selector(setOrder:)
                                     withObject:self.order];
    [self.navigationController popViewControllerAnimated:YES];
    
};

#pragma mark - Action

- (BOOL)validate
{
    if ([self.selectionTextField.text isEqualToString:@""] ||
        [self.valueTextField.text isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"Validation Error"
                                    message:@"Please fill in all values"
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil]
         show];
        return NO;
    }
    return YES;
}

- (void)performAction
{
    [self.activityView startAnimating];
    // Do Stuff...
}

- (IBAction)performActionButtonPressed:(UIButton *)sender;
{
    if (self.validate && self.siteAvailable)
        [self performAction];
}

#pragma mark - Network Connection Error Handling

- (BOOL)siteAvailable
{
    return YES;
}

#pragma mark - UX - Keyboard & Picker

- (IBAction)backgroundPressed:(UIControl *)sender
{
    [self.valueTextField resignFirstResponder];
}

- (IBAction)selectionTextFieldPressed:(UITextField *)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)])
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        self.selection = selectedIndex;
        // [self textFieldEditingDidEnd:sender];
    };
    [ActionSheetStringPicker showPickerWithTitle:self.pickerTitle rows:self.choices initialSelection:self.selection doneBlock:done cancelBlock:nil origin:sender];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // [self textFieldEditingDidBegin:textField];
    return NO;
}

- (IBAction)textFieldEditingDidBegin:(UITextField *)sender
{
    [DesignUtility modifyTextFieldActive:sender];
    [self.view animateViewUp:YES distance:100 duration:0.3f];
    self.selectionTextField.enabled = NO;
}

- (IBAction)textFieldEditingDidEnd:(UITextField *)sender
{
    [DesignUtility modifyTextField:sender];
    [self.view animateViewUp:NO distance:100 duration:0.3f];
    self.selectionTextField.enabled = YES;
}

@end
