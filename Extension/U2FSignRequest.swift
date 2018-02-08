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

class U2FSignRequest : U2FRequest {
    public static let RequestType = "u2f_sign_request"

    override var responseType : String { get { return "u2f_sign_response" } }

    let challenge : String

    override init?(requestDictionary : Dictionary, origin : URL) {
        if let challenge = requestDictionary["challenge"] as? String {
            self.challenge = challenge
            super.init(requestDictionary: requestDictionary, origin: origin)
        } else {
            return nil
        }
    }

    override func run(device : U2FDevice) throws -> U2FResponse.Data {
        return try device.sign(challenge: challenge, origin: self.origin)
    }
}
