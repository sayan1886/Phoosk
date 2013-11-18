//
//  PSDecorationView.m
//  Phoosk
//
//  Created by Joshua Eckstein on 1/8/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSDecorationView.h"

@implementation PSDecorationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.userInteractionEnabled = YES;

		_dragTarget = nil;
		_isEditableDecoration = NO;

		_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_deleteButton setFrame:CGRectMake(0, 0, 42, 42)];
		[_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
		[_deleteButton setHidden:YES];
		[_deleteButton addTarget:self
						 action:@selector(deleteButtonReceiver)
			   forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_deleteButton];

		UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
		UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(didRotate:)];
		pinch.delegate = rotate.delegate = self;
		[self addGestureRecognizer:pinch];
		[self addGestureRecognizer:rotate];
	}
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}


- (void) didPinch:(UIPinchGestureRecognizer *)pinch {
	[[PSIdleTimer sharedInstance] unidle];
	if (pinch.state == UIGestureRecognizerStateBegan) {
		prevScale = pinch.scale;
    } else {
		CGFloat nextScale = 1 - (prevScale - pinch.scale);
		nextScale = MAX(nextScale, 0.5);
		nextScale = MIN(nextScale, 2.0);
		prevScale = pinch.scale;
		self.transform = CGAffineTransformScale(self.transform, nextScale, nextScale);
    }
}

- (void) didRotate:(UIRotationGestureRecognizer *)rotation
{
	[[PSIdleTimer sharedInstance] unidle];
	if (rotation.state == UIGestureRecognizerStateBegan) {
		prevRotation = rotation.rotation;
    } else {
		CGFloat nextRotation = (rotation.rotation - prevRotation);
		prevRotation = rotation.rotation;
		self.transform = CGAffineTransformRotate(self.transform, nextRotation);
    }
}

- (void)deleteButtonReceiver
{
	[[PSIdleTimer sharedInstance] unidle];
	CGRect disappearanceRect = [self convertRect:CGRectMake(0, 0, 0, 0)
										  toView:self.superview];
	
	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.layer.transform = CATransform3DIdentity;
					 }
					 completion:^(BOOL finished) {
						 [self genieInTransitionWithDuration:1.0
											 destinationRect:disappearanceRect
											 destinationEdge:BCRectEdgeRight
												  completion:^{
													  [self removeFromSuperview];
												  }];
					 }];
}

- (void)setIsEditableDecoration:(BOOL)isEditableDecoration
{
	if(isEditableDecoration) {
		_deleteButton.alpha = 0.0;
		_deleteButton.hidden = NO;
		[UIView animateWithDuration:PSDecorationAnimationDuration
						 animations:^{
							 _deleteButton.alpha = 0.9;
						 }];
	}
	_isEditableDecoration = isEditableDecoration;
}

- (id)copyWithZone:(NSZone *)zone
{
	PSDecorationView* copy = [[PSDecorationView alloc] initWithFrame:self.frame];
	copy.image = self.image;
	copy.contentMode = self.contentMode;
	return copy;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[PSIdleTimer sharedInstance] unidle];
	startingFrame = self.frame;
	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.alpha = 0.5;
					 }];
	[self.superview bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[PSIdleTimer sharedInstance] unidle];
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.superview];
	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.center = loc;
					 }];
}

- (void) resetToStartingPosition {
	[[PSIdleTimer sharedInstance] unidle];
	if(_isEditableDecoration)
		return;

	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
						 [self setFrame:startingFrame];
						 CATransition *transition = [CATransition animation];
						 transition.duration = PSDecorationAnimationDuration;
						 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
						 transition.type = kCATransitionPush;
						 transition.subtype = kCATransitionFromTop;
						 [self.layer addAnimation:transition forKey:nil];
						 self.alpha = 1.0;
					 }];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[PSIdleTimer sharedInstance] unidle];
	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.alpha = 1.0;
					 }];
	[self setFrame:startingFrame];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[PSIdleTimer sharedInstance] unidle];
	[UIView animateWithDuration:PSDecorationAnimationDuration
					 animations:^{
						 self.alpha = 1.0;
					 }];

	if(_dragTarget) {
		UITouch *touch = [touches anyObject];
		CGPoint loc = [touch locationInView:_dragTarget];
		PSDecorationView* selfCopy = [self copy];
		selfCopy.isEditableDecoration = YES;
		CGRect newFrame = selfCopy.frame;
		newFrame.size.height *= 2;
		newFrame.size.width *= 2;
		[selfCopy setFrame:newFrame];
		selfCopy.center = loc;
		[self.dragTarget addSubview:selfCopy];
	}
	[self resetToStartingPosition];
}

- (UIResponder *)nextResponder
{
	[[PSIdleTimer sharedInstance] unidle];
	return [super nextResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
