//
//  PSIdleTimer.h
//  Phoosk
//
//  Created by Joshua Eckstein on 6/20/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSPreferenceKeys.h"

typedef void (^PSIdleTimerCompletionBlock)();

@interface PSIdleTimer : NSObject
{
	NSTimer* _idleTimer;
}

@property (nonatomic, strong) PSIdleTimerCompletionBlock idleAction;

- (void) unidle;
- (void) fire;
- (void) suspend;
+ (PSIdleTimer *) sharedInstance;

@end
