//
//  DarwinNotificationsManager.h
//  SRDemo_1
//
//  Created by yMac on 2019/6/3.
//  Copyright © 2019 cs. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef DarwinNotifications_h
#define DarwinNotifications_h
@interface DarwinNotificationsManager : NSObject
@property (strong, nonatomic) id someProperty;
+ (instancetype)sharedInstance;
- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;
@end
#endif
