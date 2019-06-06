//
//  ESPThread.m
//  SRDemo_1
//
//  Created by yMac on 2019/6/5.
//  Copyright © 2019 cs. All rights reserved.
//

#import "ESPThread.h"

@interface ESPThread()

@property(atomic, assign, getter=isInterrupt) BOOL isInterrupt;
@property(atomic, strong) NSCondition *condition;

@end

@implementation ESPThread

+ (ESPThread *)currentThread {
    return [[ESPThread alloc]init];
}

- (id)init {
    self = [super init];
    if (self)
    {
        self.isInterrupt = NO;
        self.condition = [[NSCondition alloc]init];
    }
    return self;
}

- (BOOL)sleep:(long long)milliseconds {
    [self.condition lock];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: milliseconds/1000.0];
    BOOL signaled = NO;
    while (!self.isInterrupt && (signaled = [self.condition waitUntilDate:date])) {}
    [self.condition unlock];
    return self.isInterrupt;
}

- (void)interrupt {
    [self.condition lock];
    self.isInterrupt = YES;
    [self.condition signal];
    [self.condition unlock];
    
}

@end
