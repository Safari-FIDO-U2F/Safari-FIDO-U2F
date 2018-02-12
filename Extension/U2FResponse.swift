//  ----------------------------------------------------------------
//  Created by Sam Deane on 07/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

public class U2FResponse {
    typealias Dictionary = [String:Any]
    
    let type : String
    let requestId : Int
    let responseData : Dictionary
    
    init(type : String, requestId : Int, responseData: Dictionary) {
        self.type = type
        self.requestId = requestId
        self.responseData = responseData
    }
    
    var info : [String:Any] { get {
        let info : [String:Any] = [
            "type" : type,
            "requestId" : requestId,
            "responseData" : responseData
        ]
        
        return info
        }
    }
}
