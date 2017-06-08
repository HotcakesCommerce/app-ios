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

#import "DashboardViewController.h"
#import "NSNumberFormatterFactory.h"
#import "DesignUtility.h"
#import "ErrorAlertUtility.h"
#import "UIActivityIndicatorView+MaskView.h"
#import "GoogleAnalytics.h"

@implementation DashboardViewController
{
    CGFloat buttonlabelHeight;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData:)
                                                 name:@"refreshData"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    refresh = NO;
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [GoogleAnalytics trackScreenViewWithName:@"Dashboard"];
    
    if (refresh)
    {
        refresh=NO;
        [self loadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    api = [HotcakesApi instance];
    
    activityView = [UIActivityIndicatorView maskedUIActivityIndicatorWithView:self.view];

    if (UIScreen.mainScreen.bounds.size.height == 568)
        buttonlabelHeight = 40;
    else
        buttonlabelHeight = -10;
    
    [self.readyToShipButton addSubview:[self makeOrdersLabelWithText:@"Orders\nReady to Ship"]];
    [self.awaitingPaymentButton addSubview:[self makeOrdersLabelWithText:@"Orders\nAwaiting Payment"]];

    [self loadData];
}

- (void) refreshData:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshData"] || [[notification name] isEqualToString:UIApplicationWillEnterForegroundNotification])
        refresh=YES;
}

- (void)loadData
{
    [activityView startAnimating];

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

    void (^callback) () = ^(DashboardData *result)
    {
        data = result;
        
        if ([self shippingCount] == nil)
        {
            self.shippingCount =[self makeOrdersLabelWithCount:data.readyForShippingCount];
            [self.readyToShipButton addSubview:[self shippingCount]];
        }
        else
        {
            self.shippingCount.text = [NSString stringWithFormat:@"%@", data.readyForShippingCount];
        }
        
        if ([self paymentCount] == nil)
        {
            self.paymentCount =[self makeOrdersLabelWithCount:data.readyForPaymentCount];
            [self.awaitingPaymentButton addSubview:[self paymentCount]];
        }
        else
        {
            self.paymentCount.text = [NSString stringWithFormat:@"%@", data.readyForPaymentCount];
        }
        
        [activityView stopAnimating];
        
        [self updateUI];
    };
    
    [api getDashboardDataWithCallback:callback authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status];
}

- (UILabel *)makeOrdersLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, buttonlabelHeight, 200, 100)];
    label.text = text;
    label.numberOfLines = 2;
    [DesignUtility modifyLabel:label withSize:12];
    return label;
}

- (UILabel *)makeOrdersLabelWithCount:(NSNumber *)count
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonlabelHeight, 50, 100)];
    // TODO: Format with two digits
    label.text = [NSString stringWithFormat:@"%@", count];
    label.textAlignment = NSTextAlignmentRight;
    [DesignUtility modifyLabel:label withSize:30];
    
    return label;
}

- (void)updateUI
{
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;
    self.yearLabel.text  = [formatter stringFromNumber:data.year.total];
    self.monthLabel.text = [formatter stringFromNumber:data.month.total];
    self.weekLabel.text  = [formatter stringFromNumber:data.week.total];
    self.dayLabel.text   = [formatter stringFromNumber:data.day.total];
    
    self.navigationItem.title = data.storeName;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destination = segue.destinationViewController;
    NSString *labelName;

    if ([destination respondsToSelector:@selector(setStatus:)])
    {
        NSString *status = nil;
        if (sender == self.awaitingPaymentButton)
        {
            status = @"Ready+for+payment";
            labelName = @"Orders Awaiting Payment";
        }
        if (sender == self.readyToShipButton)
        {
            status = @"Ready+for+shipping";
            labelName = @"Orders Ready To Ship";
        }
        if (status)
        {
            [GoogleAnalytics trackUXTouchWithName:labelName value:nil];
            [destination performSelector:@selector(setStatus:) withObject:status];
        }
    }
    
    if ([destination respondsToSelector:@selector(setPeriod:)])
    {
        NSString *period = @"all";
        labelName = @"All Orders";

        if (sender == self.yearButton)
        {
            period = @"year";
            labelName = @"Orders This Year";
        }
        else if (sender == self.monthButton)
        {
            period = @"month";
            labelName = @"Orders This Month";
        }
        else if (sender == self.weekButton)
        {
            period = @"week";
            labelName = @"Orders This Week";
        }
        else if (sender == self.dayButton)
        {
            period = @"day";
            labelName = @"Today's Orders";
        }
        
        [GoogleAnalytics trackUXTouchWithName:labelName value:nil];
        [destination performSelector:@selector(setPeriod:) withObject:period];
    }
}

- (IBAction)refresh:(id)sender
{
    [GoogleAnalytics trackUXTouchWithName:@"Refresh Button" value:nil];

    [self loadData];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

@end
