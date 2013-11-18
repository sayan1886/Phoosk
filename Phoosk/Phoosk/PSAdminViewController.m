//
//  PSAdminViewController.m
//  Phoosk
//
//  Created by Joshua Eckstein on 1/8/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSAdminViewController.h"
#import "PAPasscodeViewController.h"


//#import "SHKActivityIndicator.h"
//#import "SHK.h"
//#import "SHKLogout.h"

@interface PSAdminViewController ()

@end

@implementation PSAdminViewController

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

	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	[prefs synchronize];

	_autoFollowEnabledSwitch.on = [prefs boolForKey:kPSAutoFollowEnabled];
	_autoFollowAccount.text = [prefs valueForKey:kPSAutoFollowAccount];

	_autoLikeEnabledSwitch.on = [prefs boolForKey:kPSAutoLikeEnabled];
	_autoLikePageID.text = [prefs valueForKey:kPSAutoLikePageID];

	_shareURLEnabled.on = [prefs boolForKey:kPSShareURLEnabled];
	_shareURL.text = [prefs valueForKey:kPSShareURL];
	
	_decorationsEnabled.on = [prefs boolForKey:kPSDecorationsEnabled];
	
	_shareText.text = [prefs valueForKey:kPSShareText];
	_shareTitle.text = [prefs valueForKey:kPSShareTitle];

	_idleTimeSlider.value = [[prefs valueForKey:kPSIdleTime] floatValue];

	[self didChangeAutoLikeEnabledSwitch:nil];
	[self didChangeAutoFollowEnabledSwitch:nil];
	[self didChangeShareURLEnabledSwitch:nil];
	[self didChangeIdleTimeSlider:nil];
}

- (void)didChangeAutoFollowEnabledSwitch:(id)sender
{
	_autoFollowAccount.enabled = _autoFollowEnabledSwitch.on;

	if(!_autoFollowEnabledSwitch.on) {
		_autoFollowAccount.text = @"";
	}
}

- (void)didChangeAutoLikeEnabledSwitch:(id)sender
{
	_autoLikePageID.enabled = _autoLikeEnabledSwitch.on;
	
	if(!_autoLikeEnabledSwitch.on) {
		_autoLikePageID.text = @"";
	}
}

- (void)didChangeShareURLEnabledSwitch:(id)sender
{
	_shareURL.enabled = _shareURLEnabled.on;
	
	if(!_shareURLEnabled.on) {
		_shareURL.text = @"";
	}
}

- (void)didChangeIdleTimeSlider:(id)sender
{
	_idleTimeLabel.text = [NSString stringWithFormat:@"%d seconds", (int)_idleTimeSlider.value];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"info: %@", info);
	_pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[_imagePopoverController dismissPopoverAnimated:YES];
}

-(void)didPressSelectBanner:(id)sender
{
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
    _imagePopoverController.delegate = self;
    [_imagePopoverController presentPopoverFromRect:((UIButton *)sender).bounds
											 inView:sender
						   permittedArrowDirections:UIPopoverArrowDirectionAny
										   animated:YES];
}

-(IBAction)didPressCancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		[[PSIdleTimer sharedInstance] unidle];
	}];
}

-(IBAction)didPressDone:(id)sender
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];

	[prefs setBool:_autoFollowEnabledSwitch.on forKey:kPSAutoFollowEnabled];
	[prefs setValue:_autoFollowAccount.text forKey:kPSAutoFollowAccount];

	[prefs setBool:_autoLikeEnabledSwitch.on forKey:kPSAutoLikeEnabled];
	[prefs setValue:_autoLikePageID.text forKey:kPSAutoLikePageID];

	[prefs setBool:_shareURLEnabled.on forKey:kPSShareURLEnabled];
	[prefs setValue:_shareURL.text forKey:kPSShareURL];
	
	[prefs setBool:_decorationsEnabled.on forKey:kPSDecorationsEnabled];

	[prefs setValue:_shareText.text forKey:kPSShareText];
	[prefs setValue:_shareTitle.text forKey:kPSShareTitle];
	
	[prefs setValue:@((int)_idleTimeSlider.value) forKey:kPSIdleTime];

	[prefs synchronize];

	if(_pickedImage) {
		PSViewController* vc = (PSViewController *) self.presentingViewController;
		[vc.bannerView setImage:_pickedImage];
	}

	[self dismissViewControllerAnimated:YES completion:^{
		[[PSIdleTimer sharedInstance] unidle];
	}];
}

-(void)didPressChangePasscode:(id)sender
{
	PAPasscodeViewController *passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
	passcode.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    passcode.delegate = self;
	passcode.passcode = [[NSUserDefaults standardUserDefaults] stringForKey:kPSPasscode];
	[self presentViewController:passcode animated:YES completion:nil];
}

- (void)didPressLogout:(id)sender
{
	//[SHK logoutOfAll];
	
	// Notify user
	//[[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Logged Out!")];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
	[[NSUserDefaults standardUserDefaults] setValue:controller.passcode forKey:kPSPasscode];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapOutsideViewToResignFirstResponsor:(id)sender
{
	[self.view endEditing:YES];
}

- (UIResponder *)nextResponder
{
	[[PSIdleTimer sharedInstance] unidle];
	return [super nextResponder];
}

@end
