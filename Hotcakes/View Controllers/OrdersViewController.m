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

#import "OrdersViewController.h"
#import "HotcakesApi.h"
#import "NSNumberFormatterFactory.h"
#import "ErrorAlertUtility.h"
#import "GoogleAnalytics.h"

@implementation OrdersViewController
{
    // Preserves sort order ([orders allKeys] returns in alphabetical order)
    NSMutableArray *sections;
    NSMutableDictionary *orders;
    NSMutableDictionary *filteredOrders;
    
    HotcakesApi *api;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    sections = [@[@"Pending", @"Others"] mutableCopy];
    orders = [@{ @"Pending":@[], @"Others":@[] } mutableCopy];
    filteredOrders = [@{ @"Pending":@[], @"Others":@[] } mutableCopy];
    
    if (self.pageNumber == nil)
        self.pageNumber = @1;
    if (self.pageSize == nil)
        self.pageSize = @25;
    if (self.status == nil)
        self.status = @"all";
    self.hasMorePages = YES;
    
    api = [HotcakesApi instance];

    [self loadMoreData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [GoogleAnalytics trackUXTouchWithName:@"Search Orders" value:nil];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OrderSummary *order = [self getOrderFromTableView:self.tableView forIndexPath:self.tableView.indexPathForSelectedRow];
 
    if ([segue.destinationViewController respondsToSelector:@selector(setOrderSummary:)])
        [segue.destinationViewController performSelector:@selector(setOrderSummary:)
                                              withObject:order];
}

#pragma mark Utilities

- (NSMutableArray *)getOrdersForTableView:(UITableView*)tableView forSection:(NSInteger)section
{
    NSDictionary *source = [self isSearchResults:tableView] ? filteredOrders : orders;
    return source[sections[section]];
}

- (OrderSummary *)getOrderFromTableView:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    return [self getOrdersForTableView:tableView forSection:indexPath.section][indexPath.row];
}

- (void)formatStatusIndicatorsForCellFromTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath highlighted:(BOOL)highlighted
{
    if ([self indexPath:indexPath isLastRowInTableView:tableView])
        return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    OrderSummary *order = [self getOrderFromTableView:tableView forIndexPath:indexPath];
    [self formatStatusIndicatorsForCell:cell fromOrder:order highlighted:highlighted];
}

- (void)formatStatusIndicatorsForCell:(UITableViewCell *)cell fromOrder:(OrderSummary *)order highlighted:(BOOL)highlighted
{
    UIImageView *paidIcon = (UIImageView *)[cell viewWithTag:104];
    paidIcon.image = [UIImage imageNamed:[self getIconPathForAction:@"Paid" completed:order.isPaid highlighted:highlighted]];
    
    UIImageView *shippedIcon = (UIImageView *)[cell viewWithTag:105];
    shippedIcon.image = [UIImage imageNamed:[self getIconPathForAction:@"Shipped" completed:order.isShipped highlighted:highlighted]];
}

- (NSString *)getIconPathForAction:(NSString *)action completed:(BOOL)complete highlighted:(BOOL)highlighted
{
    return [NSString stringWithFormat:@"Icon-%@-%@%@", action, complete ? @"Complete" : @"Normal", highlighted ? @"-Active" : @""];
}

- (BOOL)isSearchResults:(UIView *)tableView
{
    return (tableView != self.tableView);//!= self.searchDisplayController.searchResultsTableView)
}

- (BOOL)indexPath:(NSIndexPath *)indexPath isLastRowInTableView:(UITableView *)tableView
{
    return (indexPath.row == [self getOrdersForTableView:tableView forSection:indexPath.section].count);
}

- (void)loadMoreData
{
    if (self.isLoading || !self.hasMorePages)
        return;
    
    self.isLoading = YES;
    void (^callback) (NSMutableDictionary *) = ^(NSMutableDictionary *results)
    {
        orders[@"Pending"]= [orders[@"Pending"] arrayByAddingObjectsFromArray:results[@"Pending"]];
        NSInteger count = [results[@"Pending"] count];
        self.hasMorePages = count >= self.pageSize.intValue;
        self.isLoading = NO;
        [self.tableView reloadData];
    };
    
    void (^generalError) ()   = ^(NSError *generalError){
        NSString *message   = [NSString stringWithString:generalError.localizedDescription];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^error) ()    = ^{
        NSString *message   = [NSString stringWithFormat:@"Invalid username or password"];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Login Failure"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };
    
    void (^status) ()   = ^(int code){
        NSString *message   = [NSString stringWithString:[NSString stringWithFormat:@"An error occurred processing the request: %d", code]];
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    };

    [api getOrdersWithCallback:callback authenticationErrorBlock:error generalErrorBlock:generalError statusCodeErrorBlock:status fromPeriod:self.period havingStatus:self.status pageSize:self.pageSize pageNumber:self.pageNumber];
    
    self.pageNumber = @(self.pageNumber.intValue + 1);
}

#pragma mark UITableView Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = [self getOrdersForTableView:tableView forSection:section].count;
    
    // Add space for loading cell (only support Pending Section - hard coded in API for now)
    if ([sections[section] isEqualToString:@"Pending"] && ![self isSearchResults:tableView])
        result++;
    
    return result;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL evenRow = indexPath.row % 2 == 0;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(evenRow ? @"List-LightGrey" : @"List-LightBlue")]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Orange-Normal"]];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self formatStatusIndicatorsForCellFromTableView:tableView AtIndexPath:indexPath highlighted:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // BUGFIX #6086 - highlight and scroll causes crash.
    if (indexPath.section > sections.count)
        return [tableView reloadData];
    
   [self formatStatusIndicatorsForCellFromTableView:tableView AtIndexPath:indexPath highlighted:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell
    static NSString *simpleTableIdentifier = @"OrderCell";
    static NSString *simpleLoadingTableIdentifier = @"LoadingOrderCell";
    UITableViewCell *cell = nil;
    
    // if (indexPath.row >= ([orders[@"Pending"] count] - (self.pageSize.intValue)) )
    if (indexPath.row >= ([orders[@"Pending"] count] / 3 * 2))
        [self loadMoreData];
    
    if ([self indexPath:indexPath isLastRowInTableView:tableView])
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:simpleLoadingTableIdentifier];
        
        if (self.isLoading)
            ((UILabel *)[cell viewWithTag:101]).text = @"Loading...";
        else if (self.hasMorePages)
            ((UILabel *)[cell viewWithTag:101]).text = @"Load More";
        else
            ((UILabel *)[cell viewWithTag:101]).text = @"No More Results";
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        // Order
        OrderSummary *order = [self getOrderFromTableView:tableView forIndexPath:indexPath];
        
        // Customer Name
        ((UILabel *)[cell viewWithTag:101]).text = order.customerName;
        
        // Order Number
        ((UILabel *)[cell viewWithTag:102]).text = [NSString stringWithFormat:@"Order #%@", order.orderNumber];
        
        // Total
        ((UILabel *)[cell viewWithTag:103]).text = [NSNumberFormatterFactory.localizedCurrencyFormatter stringFromNumber:order.total];
        
        // Order Date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        ((UILabel *)[cell viewWithTag:107]).text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:order.orderDate]];
        
        // Status Indicators
        [self formatStatusIndicatorsForCell:cell fromOrder:order highlighted:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];

    if ([self indexPath:indexPath isLastRowInTableView:tableView] && self.hasMorePages)
    {
        [GoogleAnalytics trackUXTouchWithName:@"Load More Orders" value:nil];

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ((UILabel *)[cell viewWithTag:101]).text = @"Loading...";
        
        [self loadMoreData];
    }
}

#pragma mark Sections
// Sectioned Table View - Just uncomment it :)
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sections[section];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -5, self.tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    
    sectionView.backgroundColor = [UIColor colorWithRed:121/255.0f green:124/255.0f blue:124/255.0f alpha:1];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, sectionView.frame.size.height)];
    
    header.backgroundColor = [UIColor clearColor];
    header.opaque = NO;
    header.font = [UIFont fontWithName:@"Helvetica" size:14];
    header.textColor = [UIColor whiteColor];
    header.text = sections[section];
    
    [sectionView addSubview:header];
    return  sectionView;
}
*/

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.customerName contains[c] %@ OR SELF.orderNumber.stringValue contains %@", searchText, searchText];
    
    filteredOrders[@"Pending"] = [orders[@"Pending"] filteredArrayUsingPredicate:predicate];
    filteredOrders[@"Others"] = [orders[@"Others"] filteredArrayUsingPredicate:predicate];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Reload search result table view
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Reload search result table view
    return YES;
}

#pragma mark - Network Connection Error Handling

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

@end
