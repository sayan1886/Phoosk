//
//  PSAdminViewController.h
//  Phoosk
//
//  Created by Joshua Eckstein on 1/8/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "PAPasscodeViewController.h"

@interface PSAdminViewController : UIViewController<PAPasscodeViewControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UISwitch* autoFollowEnabledSwitch;
@property (nonatomic, weak) IBOutlet UITextField* autoFollowAccount;
@property (nonatomic, weak) IBOutlet UISwitch* autoLikeEnabledSwitch;
@property (nonatomic, weak) IBOutlet UITextField* autoLikePageID;
@property (nonatomic, weak) IBOutlet UISwitch* decorationsEnabled;
@property (nonatomic, weak) IBOutlet UISwitch* shareURLEnabled;
@property (nonatomic, weak) IBOutlet UITextField* shareURL;
@property (nonatomic, weak) IBOutlet UITextView* shareText;
@property (nonatomic, weak) IBOutlet UITextField* shareTitle;

@property (nonatomic, weak) IBOutlet UISlider* idleTimeSlider;
@property (nonatomic, weak) IBOutlet UILabel* idleTimeLabel;

@property (nonatomic, strong) UIImagePickerController* imagePicker;
@property (nonatomic, strong) UIPopoverController* imagePopoverController;
@property (nonatomic, strong) UIImage* pickedImage;

-(IBAction)didPressCancel:(id)sender;
-(IBAction)didPressDone:(id)sender;
-(IBAction)didPressChangePasscode:(id)sender;
-(IBAction)didPressLogout:(id)sender;
-(IBAction)didPressSelectBanner:(id)sender;
-(IBAction)didChangeAutoFollowEnabledSwitch:(id)sender;
-(IBAction)didChangeAutoLikeEnabledSwitch:(id)sender;
-(IBAction)didChangeShareURLEnabledSwitch:(id)sender;
-(IBAction)didChangeIdleTimeSlider:(id)sender;
-(IBAction)didTapOutsideViewToResignFirstResponsor:(id)sender;

@end
