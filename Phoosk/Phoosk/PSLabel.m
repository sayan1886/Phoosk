//
//  PSLabel.m
//  Phoosk
//
//  Created by Joshua Eckstein on 12/20/12.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSLabel.h"

@implementation PSLabel

- (void)awakeFromNib
{
	CGFloat pointSize = self.font.pointSize;
	NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Myriad Pro"]);
	self.font = [UIFont fontWithName:@"MyriadPro-BoldIt" size:pointSize];
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
