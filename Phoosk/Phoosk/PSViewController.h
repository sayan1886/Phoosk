//
//  PSViewController.h
//  Phoosk
//
//  Created by Joshua Eckstein on 12/5/12.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PSWoodenTrayView.h"
#import "PSLikeViewController.h"
#import "PAPasscodeViewController.h"
#import "FlipView.h"
#import "AFNetworking.h"
#import "PSIdleTimer.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <Twitter/TWTweetComposeViewController.h>

#define PSAnimationDuration 0.3

@interface PSViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,PAPasscodeViewControllerDelegate,UIWebViewDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,IGSessionDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureConnection* videoConnection;

@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, assign) int countdownPlacard;
@property (nonatomic, strong) FlipView* countdownTimerLabel;
@property (nonatomic, strong) AnimationDelegate *animationDelegate;

@property (nonatomic, weak) IBOutlet UIImageView* previewImageView;
@property (nonatomic, weak) IBOutlet PSWoodenTrayView* decorationTrayView;
@property (nonatomic, weak) IBOutlet UIView* shareTrayView;
@property (nonatomic, weak) IBOutlet UIImageView* bannerView;

@property (nonatomic, weak) IBOutlet UIButton* facebookButton;
@property (nonatomic, strong) UIWebView* facebookLikeView;

@property (nonatomic, weak) IBOutlet UIButton* twitterButton;
@property (nonatomic, weak) IBOutlet UIButton* emailButton;
@property (nonatomic, weak) IBOutlet UIButton* instagramButton;


@property (nonatomic, weak) IBOutlet UIButton* cameraButtonA;
@property (nonatomic, weak) IBOutlet UIButton* cameraButtonB;

@property (nonatomic, weak) IBOutlet UIImageView* lookLeftView;
@property (nonatomic, weak) IBOutlet UIImageView* lookRightView;

@property (nonatomic, strong) NSArray* decorations;
@property (nonatomic, assign) CGFloat maxDecorationHeight;
@property (nonatomic, assign) CGFloat maxDecorationWidth;

@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, strong) UIAlertView* resetAlert;
@property (nonatomic, strong) NSTimer* resetTimer;

@property (nonatomic, retain) UIDocumentInteractionController *dic;


-(IBAction)didPressTakeAPhoto:(id)sender;
-(IBAction)didPressRetakeAPhoto:(id)sender;
-(IBAction)didDismissPhoto:(id)sender;
-(IBAction)didPressSharePhotoOnFacebook:(id)sender;
-(IBAction)didPressSharePhotoOnTwitter:(id)sender;
-(IBAction)didPressSharePhotoViaEmail:(id)sender;
-(IBAction)didPressSharePhotoViaInstagram:(id)sender;
-(IBAction)didDoActionToEnterAdminInterface:(id)sender;
-(BOOL)handleOpenURL:(NSURL*)url;

@end
