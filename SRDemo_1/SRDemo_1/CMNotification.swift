//
//  CMNotification.swift
//  SRDemo_1
//
//  Created by yMac on 2019/6/3.
//  Copyright © 2019 cs. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    public struct CMNotificationName {
        public static let uploadVideoSuccess = Notification.Name(rawValue: "uploadVideoSuccess")
    }
    
}

extension CFNotificationName {
    
//    public struct CMCFNotificationName {
//        public static let uploadVideoSuccess = CFNotificationName.init("uploadVideoSuccess" as CFString)
//    }
    public static let uploadVideoSuccess = CFNotificationName.init("uploadVideoSuccess" as CFString)
}
