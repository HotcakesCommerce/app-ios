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

#import "HttpClient.h"
#import "ErrorAlertUtility.h"

@implementation HttpClient

- (void)sendRequestWithPath:(NSString *)path
{
    NSURL *URL = [NSURL URLWithString:[self.baseURL stringByAppendingString:path]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.timeoutInterval = 30;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
}

- (void)sendRequestWithPath:(NSString *)path andSuccessBlock:(void (^)(NSData*))success
{
    self.success = success;
    [self sendRequestWithPath:path];
}

- (void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] ==0)
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        if (self.handleAuthenticationError)
            self.handleAuthenticationError();
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {

    // we only want to authorize with basic authentication
    if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    //NSLog(@"Received Response");	
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
		int status = [httpResponse statusCode];
		
		if (!((status >= 200) && (status < 300)))
        {
			if((self.handleErrorWithStatusCode))
                self.handleErrorWithStatusCode(status);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [connection cancel];
		}
        else
        {
			_data = [[NSMutableData alloc] init];
		}
	}
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    if (self.handleErrorWithNSError)
        self.handleErrorWithNSError(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    if (_data != nil)
    {
        NSString *jsonString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        if(self.success)
            self.success(_data);
    }
}

- (NetworkStatus)getConnectionStatus
{
    baseURLReachability = [Reachability reachabilityWithHostname:self.baseURL];
    return baseURLReachability.currentReachabilityStatus;
}

@end
