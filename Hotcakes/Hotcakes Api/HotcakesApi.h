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

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "HttpClient.h"

// Models
#import "DashboardData.h"
#import "OrderSummary.h"
#import "Order.h"
#import "LineItem.h"
#import "Shipper.h"
#import "HoldTransaction.h"
#import "StoreSettings.h"

@interface HotcakesApi : Singleton

@property (nonatomic, assign) BOOL isMock;

- (void)loginWithSite:(NSString*)site
             username:(NSString*)username
             password:(NSString*)password
      completionBlock:(void (^) ())completionBlock
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
generalErrorBlock:(void (^) ())generalErrorBlock
 statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (void)getStoreSettingsWithCallback:(void (^) (StoreSettings *))callback
                   generalErrorBlock:(void (^) ())generalErrorBlock;

- (void)getDashboardDataWithCallback:(void (^) (DashboardData *))callback
            authenticationErrorBlock:(void (^) ())authenticationErrorBlock
                   generalErrorBlock:(void (^) ())generalErrorBlock
                statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (void)getOrdersWithCallback:(void (^) (NSMutableDictionary *))callback
     authenticationErrorBlock:(void (^) ())authenticationErrorBlock
            generalErrorBlock:(void (^) ())generalErrorBlock
         statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
                   fromPeriod:(NSString *)period
                 havingStatus:(NSString *)status;

- (void)getOrdersWithCallback:(void (^) (NSMutableDictionary *))callback
     authenticationErrorBlock:(void (^) ())authenticationErrorBlock
            generalErrorBlock:(void (^) ())generalErrorBlock
         statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
                   fromPeriod:(NSString *)period
                 havingStatus:(NSString *)status
                     pageSize:(NSNumber *)pageSize
                   pageNumber:(NSNumber *)pageNumber;


- (void)getOrderById:(NSString *)orderId
withCallback:(void (^) (Order *))callback
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
   generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (void)getShippersById:(NSString *)orderId
           withCallback:(void (^) (NSArray *))callback
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
generalErrorBlock:(void (^) ())generalErrorBlock
   statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (void)markOrder:(NSString *)orderId
asShippedByShipper:(NSString *)code
withTrackingNumber:(NSString *)trackingNumber
      successBlock:(void (^) ())success
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (void)markOrder:(NSString *)orderId
asPaidByTransaction:(NSString *)transactionId
        withAmount:(NSString *)amount
      successBlock:(void (^) ())success
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock;

- (NetworkStatus)connectionStatus;
- (HttpClient *)getClient;

@end
