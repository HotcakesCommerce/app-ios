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
#import "OrderDetailViewController.h"
#import "HotcakesApi.h"
#import "NSNumberFormatterFactory.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "ErrorAlertUtility.h"
#import "UIActivityIndicatorView+MaskView.h"
#import "GoogleAnalytics.h"

@implementation OrderDetailViewController
{
    HotcakesApi *api;
    UIActivityIndicatorView *activityView;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData:)
                                                 name:@"refreshData"
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
    
    [GoogleAnalytics trackScreenViewWithName:@"Order Details"];
    
    if (refresh)
    {
        refresh=NO;
        [self loadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.lineItemsView.layer.borderColor = [[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] CGColor];
    self.lineItemsView.layer.borderWidth = 1;
    
    activityView = [UIActivityIndicatorView maskedUIActivityIndicatorWithView:self.view];
    api = [HotcakesApi instance];

    [self loadData];
}

- (void) loadData
{
    [activityView startAnimating];
    
    void (^generalError) ()   = ^(NSError *generalError){
        [activityView stopAnimating];
        
        self.shipButton.enabled = NO;
        self.payButton.enabled = NO;
        self.callButton.enabled = false;
        
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
        self.shipButton.enabled = NO;
        self.payButton.enabled = NO;
        self.callButton.enabled = false;
        
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
        self.shipButton.enabled = NO;
        self.payButton.enabled = NO;
        self.callButton.enabled = false;
        
        NSString *message   = [NSString stringWithString:[NSString stringWithFormat:@"An error occurred processing the request: %d", code]];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^callback) () = ^(Order *order)
    {
        self.order = order;
        [self.lineItemsTableView reloadData];
        [activityView stopAnimating];
    };
    
    [api getOrderById:self.orderSummary.orderId withCallback:callback authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status];
}

- (void) refreshData:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshData"])
        refresh = YES;
}

- (void)setOrder:(Order *)order
{
    _order = order;
    
    // need to set these properties so that the button icons are updated
    // correctly on the ordersviewcontroller
    self.orderSummary.isShipped = order.isShipped;
    self.orderSummary.isPaid = order.isPaid;
    
    [self updateUI];
}

- (void)updateUI
{
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;
    
    self.customerLabel.text = self.order.customerName;
    self.orderIdLabel.text = [NSString stringWithFormat:@"Order # %@", self.order.orderNumber];
    self.totalBalanceLabel.text = [formatter stringFromNumber:self.order.total];
    self.shippingLabel.text = [formatter stringFromNumber:self.order.shippingPrice];
    self.taxLabel.text = [formatter stringFromNumber:self.order.tax];
    self.totalDiscountsLabel.text = [formatter stringFromNumber:self.order.totalDiscounts];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    self.dateLabel.text = [dateFormatter stringFromDate:self.order.orderDate];
    
    if (self.order.isShipped)
    {
        [self.shipButton setBackgroundImage:[UIImage imageNamed:@"Button-Shipped-Complete"] forState:UIControlStateNormal];
        [self.shipButton setBackgroundImage:[UIImage imageNamed:@"Button-Shipped-Complete-Active"] forState:UIControlStateHighlighted];
    }
    
    if (self.order.isPaid)
    {
        [self.payButton setBackgroundImage:[UIImage imageNamed:@"Button-Paid-Complete"] forState:UIControlStateNormal];
        [self.payButton setBackgroundImage:[UIImage imageNamed:@"Button-Paid-Complete-Active"] forState:UIControlStateHighlighted];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setOrder:)])
        [segue.destinationViewController performSelector:@selector(setOrder:) withObject:self.order];
}

- (IBAction)callButtonPressed:(UIButton *)sender
{
    [GoogleAnalytics trackUXTouchWithName:@"Customer Information" value:nil];
    
    ABRecordRef person = ABPersonCreate();
    
    // Name
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.order.customerName), NULL);
    
    // Phone
    if (self.order.customerPhone)
    {
        NSString *phone = [NSString stringWithString:self.order.customerPhone];
        ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);//kABPersonPhoneProperty);
        ABMultiValueAddValueAndLabel(phones, (__bridge CFTypeRef)(phone),//CFBridgingRetain(phone),
                                     kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, phones, NULL);
    }
    
    // Email
    if (self.order.customerEmail)
    {
        ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);//kABPersonEmailProperty);
        ABMultiValueAddValueAndLabel(emails, (__bridge CFTypeRef)self.order.customerEmail, kABOtherLabel, NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emails, NULL);
    }
    
    // Person Viewer
    ABUnknownPersonViewController *personViewer = [[ABUnknownPersonViewController alloc] init];
    personViewer.displayedPerson = person;
    personViewer.allowsActions = YES;
    personViewer.allowsAddingToAddressBook = YES;
    [self.navigationController pushViewController:personViewer animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.order.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LineItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    LineItem *item = self.order.items[[indexPath row]];
    
    // Title
    UILabel *title = (UILabel *)[cell viewWithTag:101];
    title.text = item.productName;
    
    // Quantity
    UILabel *quantity = (UILabel *)[cell viewWithTag:102];
    quantity.text = [NSString stringWithFormat:@"%@", item.quantity];
    
    // Price
    UILabel *price = (UILabel *)[cell viewWithTag:103];
    NSNumberFormatter *formatter = NSNumberFormatterFactory.localizedCurrencyFormatter;
    
    NSDecimalNumber *itemprice = [NSDecimalNumber decimalNumberWithDecimal:[item.pricePerItem decimalValue]];
    NSDecimalNumber *qty = [NSDecimalNumber decimalNumberWithDecimal:[item.quantity decimalValue]];
    [itemprice decimalNumberByMultiplyingBy:qty];
    price.text = [formatter stringFromNumber:itemprice];
    
    return cell;
}

#pragma mark - Network Connection Error Handling

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (sender == self.shipButton)
    {
        [GoogleAnalytics trackUXTouchWithName:@"Ship Button" value:nil];
    }
    else if (sender == self.payButton)
    {
        [GoogleAnalytics trackUXTouchWithName:@"Pay Button" value:nil];
    }
    
    if (sender == self.shipButton && self.order.isShipped)
    {
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Ship Order"
                                                         message:@"Order has already been shipped"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
