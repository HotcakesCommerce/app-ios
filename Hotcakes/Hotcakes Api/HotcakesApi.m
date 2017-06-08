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

#import "HotcakesApi.h"
#import "NSObject+DictionaryAdapter.h"

@implementation HotcakesApi
{
    NSMutableData *_data;
    HttpClient *client;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isMock = false;
        client = [[HttpClient alloc] init];
    }
    return self;
}

- (void)loginWithSite:(NSString*)site
             username:(NSString*)username
             password:(NSString*)password
      completionBlock:(void (^) ())completionBlock
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
    generalErrorBlock:(void (^) ())generalErrorBlock
 statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    client.baseURL = [NSString stringWithFormat:@"http://%@/DesktopModules/hotcakes/API/mobile/v1-0/", site];
    client.username = username;
    client.password = password;

    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;
    
    [client sendRequestWithPath:@"authorize" andSuccessBlock:^(NSData *data){
        completionBlock();
    }];     
}

- (void)getStoreSettingsWithCallback:(void (^) (StoreSettings *))callback
generalErrorBlock:(void (^) ())generalErrorBlock
{
    client.handleErrorWithNSError = generalErrorBlock;
    
    [client sendRequestWithPath:@"storesettings" andSuccessBlock:^(NSData *data){
        NSError *error = nil;
        NSDictionary *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        StoreSettings *storeSettings = [StoreSettings objectWithDictionary:arr];

        callback(storeSettings);
    }];
}

- (DashboardData *)mockDashboardData
{
    NSData *jsonResponse = [@"{ \"year\":250456.46, \"month\":32587.54, \"week\":8524.12, \"day\":1125.96 }" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonResponse options:NSJSONReadingMutableContainers error:&error];
    return [DashboardData objectWithDictionary:dictionary];
}

- (void)getDashboardDataWithCallback:(void (^) (DashboardData *))callback
            authenticationErrorBlock:(void (^) ())authenticationErrorBlock
                   generalErrorBlock:(void (^) ())generalErrorBlock
                statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    if(self.isMock)
        return callback([self mockDashboardData]);
    
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;
    
    [client sendRequestWithPath:@"reports/summary" andSuccessBlock:^(NSData *data){
        NSError *error = nil;
        NSDictionary *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        DashboardData *dashboardData = [DashboardData objectWithDictionary:arr];
        
        for (NSDictionary *report in arr[@"PeriodSummaries"])
            [dashboardData setValue:[PeriodSummary objectWithDictionary:report] forKey:report[@"Period"]];
        
         callback(dashboardData);
    }];
}

- (NSMutableDictionary *)mockOrdersData
{
    NSData *jsonResponse = [@"{"
                                "\"Pending\":"
                                "["
                                    "{\"orderNumber\": 12345, \"CustomerName\":\"Jim Nelson\", \"Total\":49.99},"
                                    "{\"OrderNumber\": 12358, \"CustomerName\":\"Henry Tavares\", \"Total\":2999.99}"
                                "],"
                                "\"Others\":"
                                "["
                                    "{\"orderNumber\": 2568, \"CustomerName\":\"Ryan Morgan\", \"Total\":9.99},"
                                    "{\"OrderNumber\": 5689, \"CustomerName\":\"Raul Rodila\", \"Total\":129.99},"
                                    "{\"orderNumber\": 11587, \"CustomerName\":\"Cornelius Kruger\", \"Total\":879.99},"
                                    "{\"orderNumber\": 12547, \"CustomerName\":\"Jessica Hammer\", \"Total\":1589.99}"
                                "],"
                            "}"
                            dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonResponse options:NSJSONReadingMutableContainers error:&error];
    
    // Process Dictionaries into OrderSummary objects
    for (NSString * key in [result allKeys])
        for (int i=0; i < [result[key] count]; i++)
            result[key][i] = [OrderSummary objectWithDictionary:result[key][i]];
    
    return result;
}

- (void)getOrdersWithCallback:(void (^) (NSMutableDictionary *))callback
     authenticationErrorBlock:(void (^) ())authenticationErrorBlock
            generalErrorBlock:(void (^) ())generalErrorBlock
         statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
                   fromPeriod:(NSString *)period
                 havingStatus:(NSString *)status
{
   [self getOrdersWithCallback:callback authenticationErrorBlock:authenticationErrorBlock generalErrorBlock:generalErrorBlock statusCodeErrorBlock:statusCodeErrorBlock fromPeriod:period havingStatus:status pageSize:@5 pageNumber:@1];
}

- (void)getOrdersWithCallback:(void (^) (NSMutableDictionary *))callback
     authenticationErrorBlock:(void (^) ())authenticationErrorBlock
            generalErrorBlock:(void (^) ())generalErrorBlock
         statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
                   fromPeriod:(NSString *)period
                 havingStatus:(NSString *)status
                     pageSize:(NSNumber *)pageSize
                   pageNumber:(NSNumber *)pageNumber
{
    if(self.isMock)
        return callback([self mockOrdersData]);
    
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;

    __block NSString *pathUrl = @"orders/list?";
    NSDictionary *params =
    @{
        @"period": period,
        @"status": status,
        @"pageSize": pageSize,
        @"pageNumber": pageNumber
    };
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![pathUrl hasSuffix:@"?"])
            pathUrl = [pathUrl stringByAppendingString:@"&"];
        pathUrl = [NSString stringWithFormat:@"%@%@=%@", pathUrl, key, obj];
    }];
    
    [client sendRequestWithPath:pathUrl andSuccessBlock:^(NSData *data){
        NSError *error = nil;
        NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
       
        NSMutableDictionary *results = [@{
            @"Pending": [@[] mutableCopy],
            @"Others": [@[] mutableCopy]
        } mutableCopy];
        
        for (int i=0; i<[arr count]; i++)
        {
            NSString *targetSection = @"Pending";
            //if([arr[i][@"StatusCode"] isEqualToString:@"Complete"])
            //    targetSection = @"Others";
            
            OrderSummary *order = [OrderSummary objectWithDictionary:arr[i]];
         
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([order.orderNumber isKindOfClass:[NSString class]])
                order.orderNumber = [formatter numberFromString:(NSString *)order.orderNumber];
            
            [self setFlagsForOrder:order fromResults:arr[i]];

            [results[targetSection] addObject:order];
        }
        callback(results);
    }];
}

- (void)setFlagsForOrder:(id)order fromResults:(NSDictionary *)results
{
    [order setIsPaid:[results[@"PaymentStatus"] isEqualToString:@"Paid"] ];
    [order setIsShipped: [results[@"ShippingStatus"] isEqualToString:@"FullyShipped"]];
}
- (void)mockOrderByOrderId:(NSString *)orderId  withSuccessBlock:(void (^)(NSData*))success
{
    NSData *jsonResponse = [@"{"
                                "\"orderNumber\": 12345,"
                                "\"CustomerName\":\"Jim Nelsonn\","
                                "\"total\":49.99,"
                                "\"tax\":10.00,"
                                "\"shipping\":10.00,"
                                // "\"isShipped\":false,"
                                //    "\"isPaid\":false"
                                "\"date\":\"1/1/12\","
                                "\"Items\":"
                                "["
                                    "{ \"ProductName\":\"Product Name\", \"quantity\":2, \"price\":9.00 },"
                                    "{ \"ProductName\":\"Product Name\", \"quantity\":1, \"price\":10.99 },"
                                    "{ \"ProductName\":\"Product Name\", \"quantity\":1, \"price\":10.00 }"
                                "]"
                            "}"
                            dataUsingEncoding:NSUTF8StringEncoding];
    
    success(jsonResponse);
}

- (void)getOrderById:(NSString *)orderId withCallback:(void (^) (Order *))callback
    authenticationErrorBlock:(void (^) ())authenticationErrorBlock
        generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;

    void (^processOrder) (NSData *) = ^(NSData *data)
    {
        NSError *error = nil;
        NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        Order *result = [Order objectWithDictionary:response];
        result.items = [@[] mutableCopy];
        
        NSArray *lineItems = response[@"Items"];
        for (int i=0; i < [lineItems count]; i++)
            [result.items addObject: [LineItem objectWithDictionary:lineItems[i]]];
        
        result.pendingHolds = [@[] mutableCopy];
        NSArray *holds = response[@"PendingHolds"];
        
        // Infinite loop - each iteration for some reason adds a hold
        /*for (int i=0; i < [holds count]; i++)
        {
            NSDictionary *dict = holds[i];
            [result.pendingHolds addObject: [HoldTransaction objectWithDictionary:dict]];
        }*/
        
        for (NSDictionary *dict in holds)
            [result.pendingHolds addObject: [HoldTransaction objectWithDictionary:dict]];
        
        [self setFlagsForOrder:result fromResults:response];
        
        callback(result);
    };
    
    if(self.isMock)
        [self mockOrderByOrderId:orderId withSuccessBlock:processOrder];
    else
        [client sendRequestWithPath:[@"orders/list/" stringByAppendingString:orderId]
                    andSuccessBlock:processOrder];
}


- (void)mockShippersByOrderId:(NSString *)orderId  withSuccessBlock:(void (^)(NSData*))success
{
    NSData *jsonResponse = [@"["
                                "{ \"Name\":\"US Postal Service\", \"Code\":1 },"
                                "{ \"Name\":\"United Parcel Service\", \"Code\":2 },"
                                "{ \"Name\":\"FedEx\", \"Code\":3 },"
                                "{ \"Name\":\"Other\", \"Code\":4 }"
                            "]"
                            dataUsingEncoding:NSUTF8StringEncoding];
    
    success(jsonResponse);
}

- (void)getShippersById:(NSString *)orderId
           withCallback:(void (^) (NSArray *))callback
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
      generalErrorBlock:(void (^) ())generalErrorBlock
   statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;

    void (^processShippers) (NSData *) = ^(NSData *data)
    {
        NSError *error = nil;
        NSMutableArray *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
       
        for (int i = 0; i < [response count]; i++)
            response[i] = [Shipper objectWithDictionary:response[i]];

        callback(response);
    };
    
    if(self.isMock)
        [self mockShippersByOrderId:orderId withSuccessBlock:processShippers];
    else
        [client sendRequestWithPath:[@"orders/shipperlist/" stringByAppendingString:orderId]
                    andSuccessBlock:processShippers];
}


- (void) markOrder:(NSString *)orderId
asShippedByShipper:(NSString *)code
withTrackingNumber:(NSString *)trackingNumber
      successBlock:(void (^) ())success
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
 generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;

    if (self.isMock)
        success();
    else
        [client sendRequestWithPath:[NSString stringWithFormat:@"orders/markshipped?orderID=%@&shipperCode=%@&number=%@", orderId, code, trackingNumber] andSuccessBlock:^(NSData *response) {
            success();
        }];
}

- (void) markOrder:(NSString *)orderId
asPaidByTransaction:(NSString *)transactionId
        withAmount:(NSString *)amount
      successBlock:(void (^) ())success
authenticationErrorBlock:(void (^) ())authenticationErrorBlock
 generalErrorBlock:(void (^) ())generalErrorBlock
statusCodeErrorBlock:(void (^) ())statusCodeErrorBlock
{
    client.handleAuthenticationError = authenticationErrorBlock;
    client.handleErrorWithNSError = generalErrorBlock;
    client.handleErrorWithStatusCode = statusCodeErrorBlock;

    if (self.isMock)
        success();
    else
        [client sendRequestWithPath:[NSString stringWithFormat:@"orders/capturepayment?orderID=%@&transactionid=%@&amount=%@", orderId, transactionId, amount] andSuccessBlock:^(NSData *response) {
            success();
        }];
}

- (NetworkStatus)connectionStatus
{
    return [client getConnectionStatus];
}

- (HttpClient *)getClient
{
    return client;
}

@end
