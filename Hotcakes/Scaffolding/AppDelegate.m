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

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DashboardViewController.h"
#import "OrdersViewController.h"
#import "OrderDetailViewController.h"
#import "MarkAsShippedViewController.h"
#import "CaptureFundsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GoogleAnalytics.h"
#import "Utilities.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIImage *navBarImage = [UIImage imageNamed:@"navbar"];
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    // navigationBarAppearance.tintColor = [UIColor blackColor];
    [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                          UITextAttributeTextShadowColor: [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],
                                     UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f]
     }];
    
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    searchBarAppearance.backgroundImage = navBarImage;
    
    
    //UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    if ([Utilities isIOS7OrHigher])
    {
        [barButtonItemAppearance setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [barButtonItemAppearance setTintColor:[UIColor blackColor]];
    }
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"Button-Back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 2)];
    [barButtonItemAppearance setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setTitleTextAttributes:@{
                                UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                             UITextAttributeTextShadowColor: [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1],
                            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],
                                        UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]
     } forState:UIControlStateNormal];
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:121/255.0f green:124/255.0f blue:124/255.0f alpha:1]];
    
    UITextField *textFieldInSearchBarAppearance = [UITextField appearanceWhenContainedIn:[UISearchBar class], nil];
    [textFieldInSearchBarAppearance setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
    
    [GoogleAnalytics startTrackerWithGAId:@"UA-46568727-1"];
    
    /*
    UIButton *buttonAppearance = [UIButton appearanceWhenContainedIn:[LoginViewController class], nil];//], [DashboardViewController class], nil];
    
    buttonAppearance.backgroundColor = [UIColor colorWithRed:249/255.0f green:76/255.0f blue:43/255.0f alpha:1];
    [buttonAppearance setTitleColor:[UIColor colorWithRed:255/255.0f green:241/255.0f blue:206/255.0f alpha:1] forState:UIControlStateNormal];
    buttonAppearance.titleLabel.shadowColor =[UIColor colorWithRed:225/255.0f green:0 blue:0 alpha:1];
    buttonAppearance.titleLabel.shadowOffset =  CGSizeMake(0.0f, 1.0f);
    
    buttonAppearance= [UIButton appearanceWhenContainedIn:[DashboardViewController class], nil];
    buttonAppearance.backgroundColor = [UIColor colorWithRed:249/255.0f green:76/255.0f blue:43/255.0f alpha:1];
    [buttonAppearance setTitleColor:[UIColor colorWithRed:255/255.0f green:241/255.0f blue:206/255.0f alpha:1] forState:UIControlStateNormal];
    buttonAppearance.titleLabel.shadowColor =[UIColor colorWithRed:225/255.0f green:0 blue:0 alpha:1];
    buttonAppearance.titleLabel.shadowOffset =  CGSizeMake(0.0f, 1.0f);*/
    
    /*
    UITextField *textField = [UITextField appearance];
    textField.layer.borderColor = [[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] CGColor];
    textField.layer.borderWidth = 1.0;
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
