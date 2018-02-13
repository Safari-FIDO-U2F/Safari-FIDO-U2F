//  ----------------------------------------------------------------
//  Created by Sam Deane on 05/02/2017.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

class U2FSignRequest : U2FRequest {
    static let RequestType = "u2f_sign_request"
    static let ResponseType = "u2f_sign_response"

    override var responseType : String { get { return U2FSignRequest.ResponseType  } }

    let challenge : String

    override init?(requestDictionary : Dictionary, origin : URL) {
        if let challenge = requestDictionary["challenge"] as? String {
            self.challenge = challenge
            super.init(requestDictionary: requestDictionary, origin: origin)
        } else {
            return nil
        }
    }

    override func run(device : U2FDevice) throws -> U2FResponse.Dictionary {
        for key in self.registeredKeys {
            do {
                var request = key
                request["appId"] = self.appId
                request["challenge"] = self.challenge
                let response = try device.sign(request: request, origin: self.origin)
                return response
            } catch let error as U2FError {
                switch error {
                    case .error(let code, _):
                        if code != U2FH_AUTHENTICATOR_ERROR {
                            throw error
                        }
                    default:
                        throw error
                    }
            }
        }
        
        throw U2FError.badRequest(reason: "missing key")
    }
}
