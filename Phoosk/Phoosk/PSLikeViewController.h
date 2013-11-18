//
//  PSLikeViewController.h
//  Phoosk
//
//  Created by Joshua Eckstein on 4/24/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSIdleTimer.h"

//#import "SHKItem.h"
//#import "SHKFacebook.h"

@interface PSLikeViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView* webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* loadingView;

- (IBAction)didPressCancel:(id)sender;

@end
