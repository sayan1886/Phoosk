//
//  PSLikeViewController.m
//  Phoosk
//
//  Created by Joshua Eckstein on 4/24/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSLikeViewController.h"

@interface PSLikeViewController ()

@end

@implementation PSLikeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	_webView.delegate = self;
}

- (void)didPressCancel:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];

	[self dismissViewControllerAnimated:YES completion:^{
		[[PSIdleTimer sharedInstance] fire];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[PSIdleTimer sharedInstance] unidle];

	[self.loadingView startAnimating];

	NSString *unescapedURL = [[NSUserDefaults standardUserDefaults] valueForKey:kPSAutoLikePageID];
	NSString *escapedURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																									NULL,
																									(CFStringRef)unescapedURL,
																									NULL,
																									CFSTR("!*'();:@&=+$,/?%#[]"),
																									kCFStringEncodingUTF8));
	
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://likeproxy.herokuapp.com/%@", escapedURL]];
	NSLog(@"URL: %@", url);
	NSURLRequest* fbLikeRequest = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:fbLikeRequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[PSIdleTimer sharedInstance] unidle];
	[self.loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[PSIdleTimer sharedInstance] unidle];
	[self.loadingView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[[PSIdleTimer sharedInstance] unidle];
	NSString* url = request.URL.absoluteString;
	if([url hasPrefix:@"https://www.facebook.com/plugins/close_popup"]) {
		[self dismissViewControllerAnimated:YES completion:^{
			[[PSIdleTimer sharedInstance] fire];
		}];
	}

	return YES;
}

- (UIResponder *)nextResponder
{
	[[PSIdleTimer sharedInstance] unidle];
	return [super nextResponder];
}

@end
