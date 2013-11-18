//
//  PSDecorationView.h
//  Phoosk
//
//  Created by Joshua Eckstein on 1/8/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PSIdleTimer.h"
#import "UIView+Genie.h"

#define PSDecorationAnimationDuration 0.15

@interface PSDecorationView : UIImageView<NSCopying,UIGestureRecognizerDelegate>
{
	CGRect startingFrame;
	CGFloat prevScale;
	CGFloat prevRotation;
}

@property (nonatomic, weak) UIView* dragTarget;
@property (nonatomic, assign) BOOL isEditableDecoration;
@property (nonatomic, strong) UIButton* deleteButton;

@end
