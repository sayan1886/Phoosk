//
//  PSViewController.m
//  Phoosk
//
//  Created by Joshua Eckstein on 12/5/12.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "PSViewController.h"
#import "PSAdminViewController.h"
#import "PSDecorationView.h"
#import "PAPasscodeViewController.h"
#import "MCSAppDelegate.h"

#import <Twitter/Twitter.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DEFacebookComposeViewController.h"
#import <Accounts/Accounts.h>


//#import "SHK.h"
//#import "SHKFacebook.h"
//#import "SHKTwitter.h"
//#import "SHKMail.h"

#import "TestFlight.h"

@interface PSViewController ()

@end

@implementation PSViewController

#define kPSCheckpointTookPhoto			@"Took a photo"
#define kPSCheckpointThrewAwayPhoto		@"Threw away a photo"
#define kPSCheckpointOrientationSwitch	@"Changed orientation"
#define kPSCheckpointSharedPhoto		@"Shared a photo"

#define NSLog TFLog

- (void)_layoutPreviewLayerWithDeviceOrientation:(UIInterfaceOrientation)orientation
{
	switch (orientation) {
		case UIInterfaceOrientationLandscapeLeft:
			if(_videoConnection.supportsVideoOrientation) {
				_videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
			}
			_previewLayer.transform = CATransform3DMakeRotation(M_PI/+2.0, 0.0, 0.0, 1.0);
			break;
		case UIInterfaceOrientationLandscapeRight:
			if(_videoConnection.supportsVideoOrientation) {
				_videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
			}
			_previewLayer.transform = CATransform3DMakeRotation(M_PI/-2.0, 0.0, 0.0, 1.0);
			break;
		default:
			NSLog(@"Unknown orientation: %d", orientation);
			break;
	}

	CGRect boundsRect = _previewImageView.bounds;
	CGRect rotatedBounds = CGRectMake(_previewImageView.bounds.origin.x,		_previewImageView.bounds.origin.y,
									  _previewImageView.bounds.size.height,	_previewImageView.bounds.size.width);
	[_previewLayer setBounds:rotatedBounds];
	[_previewLayer setPosition:CGPointMake(CGRectGetMidX(boundsRect), CGRectGetMidY(boundsRect))];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (AVCaptureDevice *)_defaultDeviceForMediaType:(NSString *)mediaType inPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	for (AVCaptureDevice *device in devices) {
		if (device.position == position) {
			return device;
		}
	}

	return [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
	[[PSIdleTimer sharedInstance] unidle];

	if(![url.scheme hasPrefix:@"phoosk"])
		return NO;

	NSURL *newUrl = [NSURL URLWithString:[url.absoluteString stringByReplacingCharactersInRange:NSMakeRange(0, @"phoosk".length)
																					 withString:@""]];

	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:newUrl];
	[self.webView loadRequest:urlRequest];

	[UIView animateWithDuration:PSAnimationDuration animations:^{
		self.webView.hidden = NO;
		self.webView.alpha = 1.0;
	}];

	return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_decorations = @[
			[UIImage imageNamed:@"whale"],
			[UIImage imageNamed:@"hat-1"],
//			[UIImage imageNamed:@"hat-2"],

			[UIImage imageNamed:@"mustache-1"],
			[UIImage imageNamed:@"mustache-2"],

			[UIImage imageNamed:@"red-specs"],
			[UIImage imageNamed:@"green-specs"],
			[UIImage imageNamed:@"blue-specs"],
			[UIImage imageNamed:@"pink-specs"]
		];
	}
    return self;
}

#define PSStandardDecorationHeight (_decorationTrayView.frame.size.height * 0.6)

- (void)sendDidFinish:(NSNotification *)notification
{
	[[PSIdleTimer sharedInstance] unidle];

	NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
																		 forKey:@"device_id"];

    /*
	NSLog(@"Class returned: %@", [notification.object class]);
	if([notification.object isKindOfClass:[SHKFacebook class]]) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:kPSAutoLikeEnabled]) {
			PSLikeViewController* like = [[PSLikeViewController alloc] init];
			like.modalPresentationStyle = UIModalPresentationFormSheet;
			like.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentViewController:like animated:YES completion:nil];
		}
		[SHKFacebook getUserInfo];
		NSDictionary* userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSHKFacebookUserInfo"];
		if(userInfo) {
			[parameters setObject:userInfo
						   forKey:@"facebook"];
		}
		
	} else if([notification.object isKindOfClass:[SHKTwitter class]]) {
		[SHKTwitter getUserInfo];
		NSDictionary* userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSHKTwitterUserInfo"];
		if(userInfo) {
			[parameters setObject:userInfo
						   forKey:@"twitter"];
		}
	}*/

	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://phoosk.com/"]];
	[httpClient setParameterEncoding:AFJSONParameterEncoding];
	
	NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
															path:@"http://phoosk.com/admin/?a=app-data"
													  parameters:parameters];
	NSLog(@"Parameters: %@", parameters);
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		// Print the response body in text
		NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
	[operation start];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(_resetTimer) {
		[_resetTimer invalidate];
		_resetTimer = nil;
	}

	/* Post more */
	if(buttonIndex == alertView.cancelButtonIndex) {
		[[PSIdleTimer sharedInstance] unidle];
		return;
	}

	switch (buttonIndex) {
		case 1:
			[self didWantToResetKioskByPressingButton];
			break;
			
		default:
			break;
	}
}

- (void)didWantToResetKioskByPressingButton
{
	[self didDismissPhoto:self];
}

- (void)didWantToResetKioskByDoingNothing
{
	[_resetAlert dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[PSIdleTimer sharedInstance].idleAction = ^{
		_resetAlert = [[UIAlertView alloc] initWithTitle:@"All done?"
												 message:@"If you do nothing, the kiosk will reset in 10 seconds."
												delegate:self
									   cancelButtonTitle:@"Continue"
									   otherButtonTitles:@"Done" /* buttonIndex 1 */, nil];
		
		_resetTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
													   target:self
													 selector:@selector(didWantToResetKioskByDoingNothing)
													 userInfo:nil
													  repeats:NO];
		[_resetAlert show];
	};

	static CGFloat webViewWidth = 620;
	static CGFloat webViewHeight = 540;
	
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake((self.view.frame.size.width * 0.5) - (webViewWidth * 0.5),
															   (self.view.frame.size.height * 0.5) - (webViewHeight * 0.5),
															   webViewWidth, webViewHeight)];
	self.webView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.webView.layer.shadowOffset = CGSizeMake(0, -4.0);
	self.webView.layer.shadowOpacity = 0.5;
	self.webView.layer.shadowRadius = 16.0;
	self.webView.hidden = YES;
	self.webView.alpha = 0.0;
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendDidFinish:)
                                                 name:@"SHKSendDidFinish"
                                               object:nil];

	_maxDecorationWidth = -1.0;
	_maxDecorationHeight = -1.0;
	for(UIImage* decoration in _decorations) {
		CGFloat yScale = PSStandardDecorationHeight / decoration.size.height;
		_maxDecorationWidth = MAX(_maxDecorationWidth, decoration.size.width * yScale);
	}

	_decorationTrayView.type = iCarouselTypeCylinder;
	_decorationTrayView.clipsToBounds = NO;
	_decorationTrayView.ignorePerpendicularSwipes = YES;
	_decorationTrayView.centerItemWhenSelected = NO;

	_captureSession = [[AVCaptureSession alloc] init];
	_captureSession.sessionPreset = AVCaptureSessionPresetPhoto;

	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	[_stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];

	AVCaptureDevice *videoDevice = [self _defaultDeviceForMediaType:AVMediaTypeVideo
														 inPosition:AVCaptureDevicePositionFront];

	if (videoDevice) {
		NSError *error = nil;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([_captureSession canAddInput:videoIn]) {
				[_captureSession addInput:videoIn];
			} else {
				NSLog(@"Couldn't add video input");
			}
			if ([_captureSession canAddOutput:_stillImageOutput]) {
				[_captureSession addOutput:_stillImageOutput];
			} else {
				NSLog(@"Couldn't add still image output");
			}

		}
		else {
			NSLog(@"Couldn't create video input");
		}
	}
	else {
		NSLog(@"Couldn't create video capture device");
	}

	for (AVCaptureConnection *connection in _stillImageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				_videoConnection = connection;
				break;
			}
		}
		if (_videoConnection)
			break;
	}

	_videoConnection.videoMirrored = YES;
	
    _previewImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _previewImageView.layer.shadowOffset = CGSizeMake(0, 1);
    _previewImageView.layer.shadowOpacity = 0.5;
    _previewImageView.layer.shadowRadius = 2.0;
    _previewImageView.clipsToBounds = YES;
	
	_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
	_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	[self _layoutPreviewLayerWithDeviceOrientation:self.interfaceOrientation];
	_previewLayer.zPosition = self.view.layer.zPosition - 1.0;
	[self.view.layer addSublayer:_previewLayer];
	
	[_decorationTrayView setHidden:YES];
	[_shareTrayView setHidden:YES];

	[self.view addSubview:self.webView];
	[self.view bringSubviewToFront:self.webView];
}

- (void)_startCountownTimerLabel
{
	[[PSIdleTimer sharedInstance] unidle];

	// first flip view is a vertical flip on auto, like a news ticker
	_animationDelegate = [[AnimationDelegate alloc] initWithSequenceType:kSequenceAuto
														   directionType:kDirectionForward];
	_animationDelegate.controller = self;
	_animationDelegate.nextDuration = 1.0;
	
    _countdownTimerLabel = [[FlipView alloc] initWithAnimationType:kAnimationFlipVertical
															 frame:CGRectMake(410, 400, 204, 240)];
	_animationDelegate.transformView = _countdownTimerLabel;
	
    _countdownTimerLabel.fontSize = 240;
	//    for (UIFont *font in [UIFont familyNames]) {
	//        NSLog(@"font %@", font);
	//    }
    _countdownTimerLabel.font = @"HelveticaNeue-Bold";
    _countdownTimerLabel.fontAlignment = @"center";
    _countdownTimerLabel.textOffset = CGPointMake(0.0, -32.0);
    _countdownTimerLabel.textTruncationMode = kCATruncationNone;
	_countdownTimerLabel.sublayerCornerRadius = 12.0f;

    UIColor *phooskGrey = [UIColor colorWithRed:0.247 green:0.247 blue:0.251 alpha:1.000];
    [_countdownTimerLabel printText:@"1" usingImage:nil backgroundColor:phooskGrey textColor:[UIColor whiteColor]];
    [_countdownTimerLabel printText:@"2" usingImage:nil backgroundColor:phooskGrey textColor:[UIColor whiteColor]];
    [_countdownTimerLabel printText:@"3" usingImage:nil backgroundColor:phooskGrey textColor:[UIColor whiteColor]];
    [_countdownTimerLabel printText:@"4" usingImage:nil backgroundColor:phooskGrey textColor:[UIColor whiteColor]];
    [_countdownTimerLabel printText:@"5" usingImage:nil backgroundColor:phooskGrey textColor:[UIColor whiteColor]];
	[self.view addSubview:_countdownTimerLabel];

	[_animationDelegate startAnimation:kDirectionForward];
	_countdownTimerLabel.hidden = NO;
	_countdownPlacard = 5;
}

- (void)animationDidFinish:(int)direction
{
	[[PSIdleTimer sharedInstance] unidle];

	_countdownPlacard--;
	[self.view bringSubviewToFront:[self _lookHereView]];

	if(_countdownPlacard == 1) {
		[_countdownTimerLabel genieInTransitionWithDuration:0.5
											destinationRect:[self _lookHereView].frame
											destinationEdge:[self _lookHereViewEdge]
												 completion:^{
													 [_countdownTimerLabel removeFromSuperview];
												 }];
	}
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
	switch (option) {
        case iCarouselOptionArc:
			return M_PI * 0.4;

		case iCarouselOptionShowBackfaces:
			return NO;
			
		default:
			return value;
	}
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
	return [_decorations count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	PSDecorationView* imageView = (PSDecorationView*) view;

	if(imageView == nil) {
		imageView = [[PSDecorationView alloc] initWithFrame:CGRectMake(0, 0, _maxDecorationWidth, PSStandardDecorationHeight)];
		[imageView setContentMode:UIViewContentModeScaleAspectFit];
		[imageView setUserInteractionEnabled:YES];
		[imageView setDragTarget:_previewImageView];
//		UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//																					action:@selector(doesWantToSwipeCarouselObject:)];
//		swipe.direction = UISwipeGestureRecognizerDirectionUp;
//		[imageView addGestureRecognizer:swipe];
	}

	imageView.image = _decorations[index];
	return imageView;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
	if(!carousel.hidden) {
		[[PSIdleTimer sharedInstance] unidle];
	}
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
	return _maxDecorationWidth;
}


-(void)viewWillAppear:(BOOL)animated
{
	[_captureSession startRunning];
}

-(void)_uploadPhotoToBackend:(UIImage *)image
{
	NSData *imageToUpload = UIImageJPEGRepresentation(image, 0.95);
	AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://phoosk.com"]];
	
	NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"/admin/?a=app-up" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		[formData appendPartWithFileData:imageToUpload name:@"file" fileName:@"phoosk" mimeType:@"image/jpeg"];
	}];
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *response = [operation responseString];
		NSLog(@"success: %@", response);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSString *response = [operation responseString];
		NSLog(@"failure: %@", response);
	}];

	[operation start];
}

- (void)viewDidAppear:(BOOL)animated
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	if(![defaults stringForKey:kPSPasscode]) {
		[[PSIdleTimer sharedInstance] unidle];

		PAPasscodeViewController* passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
		passcode.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		passcode.delegate = self;

		// Some defaults since we're probably running for the first time.
		[defaults setBool:NO forKey:kPSAutoFollowEnabled];
		[defaults setValue:@"" forKey:kPSAutoFollowAccount];

		[defaults setBool:NO forKey:kPSAutoLikeEnabled];
		[defaults setValue:@"" forKey:kPSAutoLikePageID];

		[defaults setBool:YES forKey:kPSDecorationsEnabled];

		[defaults setValue:@"" forKey:kPSShareURL];
		[defaults setBool:NO forKey:kPSShareURLEnabled];

		[defaults setValue:@"" forKey:kPSShareTitle];
		[defaults setValue:@"" forKey:kPSShareText];

		[defaults setValue:@(20) forKey:kPSIdleTime];

		[self presentViewController:passcode animated:YES completion:nil];
	} else {
		[[PSIdleTimer sharedInstance] suspend];
	}
}

-(void)viewDidDisappear:(BOOL)animated
{
	[_captureSession stopRunning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[TestFlight passCheckpoint:kPSCheckpointOrientationSwitch];
	[self _layoutPreviewLayerWithDeviceOrientation:toInterfaceOrientation];
}

- (void) _fadeInView:(UIView*)view withSubtype:(NSString *)subtype
{
	CATransition *transition = [CATransition animation];
	transition.duration = PSAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	transition.type = kCATransitionPush;
	transition.subtype = subtype;

	[view.layer addAnimation:transition forKey:nil];
	view.hidden = NO;
}


- (void) _fadeOutView:(UIView*)view withSubtype:(NSString *)subtype
{
	CATransition *transition = [CATransition animation];
	transition.duration = PSAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	transition.type = kCATransitionReveal;
	transition.subtype = subtype;

	[view.layer addAnimation:transition forKey:nil];
	view.hidden = YES;
}

- (UIImageView *) _lookHereView
{
	switch (self.interfaceOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			return _lookLeftView;
		case UIDeviceOrientationLandscapeRight:
			return _lookRightView;
		default:
			return nil;
	}
}

- (BCRectEdge) _lookHereViewEdge
{
	switch (self.interfaceOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			return BCRectEdgeRight;
		case UIDeviceOrientationLandscapeRight:
			return BCRectEdgeLeft;
		default:
			return nil;
	}
}


#define kPSPhotoDelay 5
#define PSLookHereAnimationDuration 0.083

- (UIImage*)_flattenView:(UIView *)view
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [view bounds].size;
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
	
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
	
    // Restore the context
    CGContextRestoreGState(context);
	
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    return image;
}


- (void)_capturePhotoFromScratch:(BOOL)fromScratch andSender:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];

	UIButton* cameraButton = (UIButton*) sender;
	UIImageView* lookHereView = [self _lookHereView];

	[TestFlight passCheckpoint:kPSCheckpointTookPhoto];
	
	/* Remove decorations */
	[[_previewImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	/* Disable camera button during this time, even though it'll be hidden. */
	BOOL wasEnabled = cameraButton.enabled;
	[cameraButton setEnabled:NO];

	/* Animate the look-here view. */
	[UIView animateWithDuration:PSLookHereAnimationDuration
						  delay:1.0
						options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 lookHereView.alpha = 1.0;
					 }
					 completion:nil];

	/* Animate the look-here view. */
	[self _startCountownTimerLabel];

	if(fromScratch) {
		[self _fadeOutView:_cameraButtonA withSubtype:kCATransitionFromBottom];
	}

	int64_t delayInSeconds = kPSPhotoDelay;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
#if !(TARGET_IPHONE_SIMULATOR)
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:_videoConnection
												   completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
		 NSData* data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
		 _previewImageView.image = _photo = [UIImage imageWithData:data];
#else
		 _previewImageView.image = _photo = [UIImage imageNamed:@"DemoImage.jpg"];
#endif

		 [self _fadeInView:_previewImageView withSubtype:kCATransitionFromLeft];

		 if(fromScratch) {
			 NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
			 if([prefs boolForKey:kPSDecorationsEnabled]) {
				 [self _fadeInView:_decorationTrayView withSubtype:kCATransitionFromTop];
			 }
			 [self _fadeInView:_shareTrayView withSubtype:kCATransitionFromRight];
		 }
		 
		 [UIView animateWithDuration:PSLookHereAnimationDuration
							   delay:0.0
							 options:UIViewAnimationOptionBeginFromCurrentState
						  animations:^{
							  [self _lookHereView].alpha = 0.0;
						  }
						  completion:nil];

		 [cameraButton setEnabled:wasEnabled];
		 [_twitterButton setEnabled:YES];
		 [_emailButton setEnabled:YES];

#if !(TARGET_IPHONE_SIMULATOR)
	 }];
#endif
	});
}

- (void)didPressRetakeAPhoto:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];
	[self _capturePhotoFromScratch:NO andSender:sender];
}


- (void)didPressTakeAPhoto:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];
	[self _capturePhotoFromScratch:YES andSender:sender];
}

-(IBAction)didDismissPhoto:(id)sender {
	[[PSIdleTimer sharedInstance] suspend];

	[TestFlight passCheckpoint:kPSCheckpointThrewAwayPhoto];
	
	[self _fadeOutView:_previewImageView withSubtype:kCATransitionFromRight];
	[self _fadeOutView:_decorationTrayView withSubtype:kCATransitionFromBottom];
	[self _fadeOutView:_shareTrayView withSubtype:kCATransitionFromLeft];
	[self _fadeInView:_cameraButtonA withSubtype:kCATransitionFromBottom];

	_previewImageView.image = _photo = nil;
	[_twitterButton setEnabled:NO];
	[_emailButton setEnabled:NO];

	if(self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
	}
	
	if (!self.webView.hidden) {
		[UIView animateWithDuration:PSAnimationDuration animations:^{
			self.webView.alpha = 0.0;
		} completion:^(BOOL finished) {
			self.webView.hidden = YES;
		}];
	}

	///[SHK logoutOfAll];
}
/*
- (SHKItem *) _photoItem:(BOOL)switchTextAndTitle andAppendLink:(BOOL)appendLink
{
	for (PSDecorationView* decorationView in _previewImageView.subviews) {
		decorationView.deleteButton.hidden = YES;
	}
	[_previewImageView addSubview:_bannerView];
	UIImage* flattenedImageView = [self _flattenView:_previewImageView];
	[_bannerView removeFromSuperview];
	[self.view addSubview:_bannerView];
	[self.view bringSubviewToFront:_bannerView];
	for (PSDecorationView* decorationView in _previewImageView.subviews) {
		decorationView.deleteButton.hidden = NO;
	}

	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	SHKItem *item = [SHKItem new];
	item.shareType = SHKShareTypeImage;
	item.image = flattenedImageView;

	NSString* text = [prefs valueForKey:kPSShareText];

	if(appendLink && [prefs boolForKey:kPSShareURLEnabled]) {
		text = [text stringByAppendingFormat:@"\n\n%@", [prefs valueForKey:kPSShareURL]];
	}
	
	if(switchTextAndTitle) {
		item.title = text;
		item.text = [prefs valueForKey:kPSShareTitle];
	} else {
		item.title = [prefs valueForKey:kPSShareTitle];
		item.text = text;
	}

	if([prefs boolForKey:kPSShareURLEnabled]) {
		item.URL = [NSURL URLWithString:[prefs valueForKey:kPSShareURL]];
	}

	return item;
}
*/
- (IBAction)didPressSharePhotoOnTwitter:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];
	//[SHKTwitter shareItem:[self _photoItem:NO andAppendLink:YES]];
    
    TWTweetComposeViewController *tweetView = [[TWTweetComposeViewController alloc] init];
    
    TWTweetComposeViewControllerCompletionHandler
    completionHandler = ^(TWTweetComposeViewControllerResult result)
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            ;
        }];
    };
    [tweetView setCompletionHandler:completionHandler];
    [tweetView setInitialText:@"Phoosk"];
    [tweetView addImage:self.previewImageView.image];
    [self presentViewController:tweetView animated:YES completion:^{ }];
    
    /*
    Class TWTweetComposeViewControllerClass = NSClassFromString(@"TWTweetComposeViewController");
    
    if (TWTweetComposeViewControllerClass != nil) {
        if([TWTweetComposeViewControllerClass respondsToSelector:@selector(canSendTweet)]) {
            UIViewController *twitterViewController = [[TWTweetComposeViewControllerClass alloc] init];
            
            [twitterViewController performSelector:@selector(setInitialText:)
                                        withObject:@""];
                        
            [twitterViewController performSelector:@selector(addImage:)
                                        withObject:self.previewImageView.image];
            [self.navigationController presentViewController:twitterViewController animated:YES completion:^{
                ;
            }];
            //[twitterViewController release];
        }
        else {
            // Use ShareKit for previous versions of iOS
        }
    }*/
    
}

- (void)didPressSharePhotoOnFacebook:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];
	//[SHKFacebook shareItem:[self _photoItem:YES andAppendLink:YES]];
    
    DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] init];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [facebookViewComposer setInitialText:@"Phoosk"];
    
    // optional
    [facebookViewComposer addImage:self.previewImageView.image];
    // or
    // optional
    //    [facebookViewComposer addURL:@"http://applications.3d4medical.com/heart_pro.php"];
    
    [facebookViewComposer setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
        switch (result) {
            case DEFacebookComposeViewControllerResultCancelled:
                NSLog(@"Facebook Result: Cancelled");
                break;
            case DEFacebookComposeViewControllerResultDone:
                NSLog(@"Facebook Result: Sent");
                break;
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            ;
        }];
    }];
    
    [self presentViewController:facebookViewComposer animated:YES completion:^{ }];
    
}

-(IBAction)didPressSharePhotoViaInstagram:(id)sender
{
//    MCSAppDelegate* appDelegate = (MCSAppDelegate*)[UIApplication sharedApplication].delegate;
//    
//    // here i can set accessToken received on previous login
//    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
//    appDelegate.instagram.sessionDelegate = self;
//    if ([appDelegate.instagram isSessionValid]) {
//        ; // post image to instagram
//
//    } else {
//        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
//    }
        [self ShareInstagram];
}

-(void)ShareInstagram
{
   //[self storeimage];
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIGraphicsEndImageContext();
//    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
//    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
//    self.dic.UTI = @"com.instagram.photo";
//    self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//    [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
    NSData *imageData = UIImageJPEGRepresentation(self.previewImageView.image, 1.0);
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    if (![imageData writeToFile:writePath atomically:YES]) {
            // failure
        NSLog(@"image save failed to path %@", writePath);
//        [self activityDidFinish:NO];
        return;
    } else {
            // success.
    }
    
        // send it to instagram.
    NSURL *fileURL = [NSURL fileURLWithPath:writePath];
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.dic.delegate = self;
    [self.dic setUTI:@"com.instagram.exclusivegram"];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
    }
    else {
        NSLog(@"No Instagram Found");
    }
    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
    
}

- (IBAction)didPressSharePhotoViaEmail:(id)sender
{
	[[PSIdleTimer sharedInstance] unidle];
	//[SHKMail shareItem:[self _photoItem:NO andAppendLink:NO]];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        {
            [self displayComposerSheetForMail];
        }
    }
}
#pragma Mail composer.

-(void)displayComposerSheetForMail
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    NSString *strSubject = @"Help me work toward my blood pressure goals";
    [mailComposer setSubject:strSubject];
    
    UIImage *savedImage = self.previewImageView.image;
    NSData *imageData = UIImagePNGRepresentation(savedImage);
    [mailComposer addAttachmentData:imageData mimeType:@"image/png" fileName:@"photo"];
    
    [mailComposer setMessageBody:@"Hi" isHTML:YES];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [self.navigationController presentViewController:mailComposer animated:YES completion:^{
            ;
        }];
    }
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismiss];
    
    if(result == MFMailComposeResultSent)
    {
        
    }
}

-(void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

-(IBAction)didDoActionToEnterAdminInterface:(id)sender
{
	if(self.presentedViewController)
		return;

	PAPasscodeViewController *passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
	passcode.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    passcode.delegate = self;
	passcode.passcode = [[NSUserDefaults standardUserDefaults] stringForKey:kPSPasscode];
    [self presentViewController:passcode animated:YES completion:^{
		[[PSIdleTimer sharedInstance] suspend];
	}];
}

#pragma mark -
#pragma mark - Lock Screen Delegate Methods
- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:controller.passcode forKey:kPSPasscode];
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"PIN entry cancelled");
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:^{
		PSAdminViewController* admin = [[PSAdminViewController alloc] init];
		admin.modalPresentationStyle = UIModalPresentationFormSheet;
		admin.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:admin animated:YES completion:nil];
	}];
}

- (UIResponder *)nextResponder
{
	[[PSIdleTimer sharedInstance] unidle];
	return [super nextResponder];
}

@end
