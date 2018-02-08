//
//  U2FRequest.swift
//  Safari FIDO U2F
//
//  Created by Sam Deane on 05/02/2017.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

class U2FRegisterRequest : U2FRequest {
    static let RequestType = "u2f_register_request"
    
    override var responseType : String { get { return "u2f_register_response" } }

    let registerRequest : U2FRequestDictionary
    
    override init?(requestDictionary : U2FRequestDictionary, origin : String) {
        guard let registerRequests = requestDictionary["registerRequests"] as? [U2FRequestDictionary] else {
            return nil
        }
        
        guard registerRequests.count > 0 else {
            return nil
        }
        
        self.registerRequest = registerRequests[0]
        super.init(requestDictionary: requestDictionary, origin: origin)
    }

    override func run(device : U2FDevice) throws -> U2FResponse.Dictionary {
        return try device.register(request: registerRequest, origin: self.origin)
    }
}

