//  ----------------------------------------------------------------
//  Created by Sam Deane on 05/02/2017.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

class U2FRegisterRequest : U2FRequest {
    static let RequestType = "u2f_register_request"
    static let ResponseType = "u2f_register_response"

    override var responseType : String { get { return U2FRegisterRequest.ResponseType  } }

    let registerRequest : Dictionary
    
    override init?(requestDictionary : Dictionary, origin : URL) {
        guard let registerRequest = U2FRequest.find(key: "registerRequests", version: U2FDevice.VERSION, in: requestDictionary) else {
            return nil
        }
        
        self.registerRequest = registerRequest
        super.init(requestDictionary: requestDictionary, origin: origin)
    }

    override func run(device : U2FDevice) throws -> U2FResponse.Data {
        var request = registerRequest
        request["appId"] = self.appId
        return try device.register(request: request, origin: self.origin)
    }
}

