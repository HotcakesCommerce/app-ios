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

@interface Order : NSObject

@property (nonatomic, retain) NSString *orderId;
@property (nonatomic, retain) NSNumber *orderNumber;
@property (nonatomic, retain) NSMutableString *customerName;
@property (nonatomic, retain) NSString *customerPhone;
@property (nonatomic, retain) NSString *customerEmail;

@property (nonatomic, retain) NSDate *orderDate;

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *pendingHolds;

@property (nonatomic, retain) NSNumber *totalDiscounts;
@property (nonatomic, retain) NSNumber *tax;
@property (nonatomic, retain) NSNumber *shippingPrice;
@property (nonatomic, retain) NSNumber *total;

@property (nonatomic, retain) NSNumber *paymentAmountAuthorized;
@property (nonatomic, retain) NSNumber *paymentAmountCharged;
@property (nonatomic, retain) NSNumber *paymentAmountDue;
@property (nonatomic, retain) NSNumber *paymentAmountRefunded;

@property (nonatomic, retain) NSString *specialInstructions;

@property (nonatomic, assign) BOOL isShipped;
@property (nonatomic, assign) BOOL isPaid;

@end
