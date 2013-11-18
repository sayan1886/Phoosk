//
//  MCSAppDelegate.h
//  Phoosk
//
//  Created by Aftab on 13/11/13.
//  Copyright (c) 2013 MCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "PSIdleTimer.h"
#import <FacebookSDK/FacebookSDK.h>


@class MCSViewController;

@interface MCSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController* navController;
@property (strong, nonatomic) Instagram *instagram;

@end


/*


Client ID 	952cbd7d2e9d49f7b7a813a7badea7d7
Client Secret 	e65658165e104eba9aff1322f6eb879b
Website URL 	http://mcsapps.wordpress.com/
Redirect URI 	http://com.aftab.phoosk

*/