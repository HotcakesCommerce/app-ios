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

#import <UIKit/UIKit.h>
#import "HotcakesApi.h"
#import "GoogleAnalytics.h"

@interface OrderActionViewController : UIViewController <UITextFieldDelegate>

#pragma mark - Internal state
@property (nonatomic, retain) HotcakesApi *api;
@property (nonatomic, assign) NSInteger selection;
@property (nonatomic, retain) NSMutableArray *choices;
@property (nonatomic, retain) NSMutableArray *choiceObjects;

#pragma mark - Validation
@property (nonatomic, retain) NSMutableArray *ValidationRules;

#pragma mark - Order Information
@property (nonatomic, retain) Order *order;
@property (weak, nonatomic) IBOutlet UILabel *customerLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

#pragma mark - Order Action Interface
@property (nonatomic, retain) NSString *pickerTitle;
@property (weak, nonatomic) IBOutlet UITextField *selectionTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIButton *performActionButton;

#pragma mark - Invalid Action Toggling
@property (weak, nonatomic) IBOutlet UILabel *invalidActionLabel;
@property (weak, nonatomic) IBOutlet UIView *actionView;

#pragma mark - UI State
- (void)updateUI;
- (void)popWithOrder;

#pragma mark - Action
- (BOOL)validate;
- (void)performAction;
- (IBAction)performActionButtonPressed:(UIButton *)sender;

#pragma mark - UX - Keyboard & Picker
- (IBAction)backgroundPressed:(UIControl *)sender;
- (IBAction)selectionTextFieldPressed:(UITextField *)sender;

#pragma mark - Network Connection Error Handling
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end
