//
//  PSWoodenTrayView.m
//  Phoosk
//
//  Created by Joshua Eckstein on 1/3/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSWoodenTrayView.h"

@implementation PSWoodenTrayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"purty_wood"]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	//// General Declarations
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//// Shadow Declarations
	UIColor* shadow = [UIColor blackColor];
	CGSize shadowOffset = CGSizeMake(0.1, 6.1);
	CGFloat shadowBlurRadius = 32;
	
	//// Rectangle Drawing
	UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
	[[UIColor clearColor] setFill];
	[rectanglePath fill];
	
	////// Rectangle Inner Shadow
	CGRect rectangleBorderRect = CGRectInset([rectanglePath bounds], -shadowBlurRadius, -shadowBlurRadius);
	rectangleBorderRect = CGRectOffset(rectangleBorderRect, -shadowOffset.width, -shadowOffset.height);
	rectangleBorderRect = CGRectInset(CGRectUnion(rectangleBorderRect, [rectanglePath bounds]), -1, -1);
	
	UIBezierPath* rectangleNegativePath = [UIBezierPath bezierPathWithRect: rectangleBorderRect];
	[rectangleNegativePath appendPath: rectanglePath];
	rectangleNegativePath.usesEvenOddFillRule = YES;
	
	CGContextSaveGState(context);
	{
		CGFloat xOffset = shadowOffset.width + round(rectangleBorderRect.size.width);
		CGFloat yOffset = shadowOffset.height;
		CGContextSetShadowWithColor(context,
									CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
									shadowBlurRadius,
									shadow.CGColor);
		
		[rectanglePath addClip];
		CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectangleBorderRect.size.width), 0);
		[rectangleNegativePath applyTransform: transform];
		[[UIColor grayColor] setFill];
		[rectangleNegativePath fill];
	}
	CGContextRestoreGState(context);
}

- (UIResponder *)nextResponder
{
	[[PSIdleTimer sharedInstance] unidle];
	return [super nextResponder];
}

@end
