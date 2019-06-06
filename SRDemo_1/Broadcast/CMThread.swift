//
//  CMThread.swift
//  SRDemo_1
//
//  Created by yMac on 2019/6/5.
//  Copyright © 2019 cs. All rights reserved.
//

import Foundation

class CMThread {
    
    var isInterrup: Bool = false
    var condition: NSCondition!

    init() {
        self.condition = NSCondition.init()
    }
    
    func sleep(milliseconds: Double) -> Bool {

        condition.lock()
        let date = Date.init(timeIntervalSinceNow: milliseconds / 1000.0)
        var signaled = condition.wait(until: date)
        while !isInterrup && signaled {
            signaled = condition.wait(until: date)
        }
        condition.unlock()
        return isInterrup
    }
    
    func interrupt() {
        condition.lock()
        isInterrup = true
        condition.signal()
        condition.unlock()
    }
    
}
