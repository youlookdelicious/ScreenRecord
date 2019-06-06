//
//  ESPThread.h
//  SRDemo_1
//
//  Created by yMac on 2019/6/5.
//  Copyright © 2019 cs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPThread : NSObject

+ (ESPThread *)currentThread;

- (BOOL)sleep:(long long)milliseconds;

- (void)interrupt;

- (BOOL)isInterrupt;


@end

NS_ASSUME_NONNULL_END
