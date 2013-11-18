//
//  PSIdleTimer.m
//  Phoosk
//
//  Created by Joshua Eckstein on 6/20/13.
//  Copyright (c) 2013 Phoosk LLC. All rights reserved.
//

#import "PSIdleTimer.h"

@interface PSIdleTimer ()
- (void)_performIdleAction;
@end

@implementation PSIdleTimer

+ (PSIdleTimer *) sharedInstance
{
	static PSIdleTimer* _sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[PSIdleTimer alloc] init];
	});
	return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)unidle
{
	NSLog(@"Idle timer unidled.");
	if(_idleTimer) {
		[_idleTimer invalidate];
	}
	
	float idleTime = [[[NSUserDefaults standardUserDefaults] valueForKey:kPSIdleTime] floatValue];
	idleTime = MAX(idleTime, 10.0);

	_idleTimer = [NSTimer scheduledTimerWithTimeInterval:idleTime
												  target:self
												selector:@selector(_performIdleAction)
												userInfo:nil
												 repeats:NO];
}

- (void)suspend
{
	NSLog(@"Idle timer suspended.");
	if(_idleTimer) {
		[_idleTimer invalidate];
	}
}

- (void) fire
{
	NSLog(@"Idle timer action manually invoked.");
	if(_idleTimer) {
		[_idleTimer invalidate];
	}
	[self _performIdleAction];
}

- (void)_performIdleAction
{
	if(_idleAction) {
		_idleAction();
	} else {
		NSLog(@"You need to set an idleAction on PSIdleTimer before it will do anything.");
	}
}

@end
