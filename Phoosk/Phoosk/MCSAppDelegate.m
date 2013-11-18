//
//  MCSAppDelegate.m
//  Phoosk
//
//  Created by Aftab on 13/11/13.
//  Copyright (c) 2013 MCS. All rights reserved.
//

#import "MCSAppDelegate.h"
#import "PSViewController.h"
#import "PSSharingConfiguration.h"
#import "MCSViewController.h"

#import "TestFlight.h"

#define APP_ID @"fd725621c5e44198a5b8ad3f7a0ffa09"

@implementation MCSAppDelegate

@synthesize navController = _navController;
@synthesize instagram = _instagram;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    
    /* Hide status bar. */
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
	/* Disable the low-power idle timer. */
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
	/* Brightness up. */
	[[UIScreen mainScreen] setBrightness:1.0];
    
	NSDictionary *headerFont = @{ UITextAttributeFont:[UIFont fontWithName:@"Avenir-Medium" size:19.0] };
	NSDictionary *smallerFont = @{ UITextAttributeFont:[UIFont fontWithName:@"Avenir-Black" size:14.0] };
	UIColor* fuschia = [UIColor colorWithRed:0.710 green:0.165 blue:0.427 alpha:1.000];
	[[UINavigationBar appearance] setTitleTextAttributes:headerFont];
	[[UIBarButtonItem appearance] setTitleTextAttributes:smallerFont forState:UIControlStateNormal];
    
	[[UINavigationBar appearance] setTintColor:fuschia];
	[[UISwitch appearance] setOnTintColor:fuschia];
    
	/* Configure ShareKit. */
//	DefaultSHKConfigurator *configurator = [[PSSharingConfiguration alloc] init];
//    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
//	[SHK logoutOfAll];
    
	/* TestFlight go. */
    [TestFlight takeOff:@"c9024506-ef69-44df-8a2d-4ffbe5b030d2"];
    
	PSViewController* viewController = [[PSViewController alloc] initWithNibName:@"PSViewController" bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.navController.navigationBarHidden = YES;
    
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)handleOpenURL:(NSURL*)url
{
	[[PSIdleTimer sharedInstance] unidle];
    return [self.instagram handleOpenURL:url];
    
    /*
	NSLog(@"%s: %@", __func__, url);
	NSString* scheme = [url scheme];
	NSString* fbPrefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
	if ([scheme hasPrefix:fbPrefix]) {
		[UIView animateWithDuration:PSAnimationDuration animations:^{
			self.viewController.webView.alpha = 0.0;
		} completion:^(BOOL finished){
			self.viewController.webView.hidden = YES;
			[SHKFacebook handleOpenURL:url];
		}];
	} else if ([scheme hasPrefix:@"phoosk"]) {
		return [self.viewController handleOpenURL:url];
	}*/
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self.instagram handleOpenURL:url];
	//return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [self handleOpenURL:url];
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
	//[SHKFacebook handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	//[SHKFacebook handleWillTerminate];
}

@end
