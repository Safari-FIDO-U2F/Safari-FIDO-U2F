//
//  U2FResponse.swift
//  application
//
//  Created by Sam Deane on 07/02/2018.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation
import SafariServices

public class U2FResponse {
    typealias Data = Any
    
    let type : String
    let requestId : Int
    let responseData : Data
    
    init(type : String, requestId : Int, responseData: Data) {
        self.type = type
        self.requestId = requestId
        self.responseData = responseData
    }
    
    func sendTo(page: SFSafariPage) {
        let info : Dictionary = [
            "type" : type,
            "requestId" : requestId,
            "responseData" : responseData
        ]

        page.dispatchMessageToScript(withName: self.type, userInfo: info)
    }
}
