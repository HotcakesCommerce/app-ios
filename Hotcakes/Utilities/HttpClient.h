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
#import "Reachability.h"

@interface HttpClient : NSObject
{
    NSMutableData *_data;
    Reachability *baseURLReachability;
}

@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, copy) void (^success)(NSData*);
@property (nonatomic, copy) void (^handleAuthenticationError)();
@property (nonatomic, copy) void (^handleErrorWithStatusCode)(int);
@property (nonatomic, copy) void (^handleErrorWithNSError)(NSError *);

- (void)sendRequestWithPath:(NSString *)path;
- (void)sendRequestWithPath:(NSString *)path andSuccessBlock:(void (^)(NSData*))success;

- (NetworkStatus)getConnectionStatus;

@end
