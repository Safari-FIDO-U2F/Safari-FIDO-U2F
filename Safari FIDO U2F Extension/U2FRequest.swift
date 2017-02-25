//
//  U2FRequest.swift
//  Safari FIDO U2F
//
//  Created by Sam Deane on 05/02/2017.
//  Copyright © 2017 Sam Deane. All rights reserved.
//  Based on origin code Copyright © 2017 Yikai Zhao. All rights reserved.
//

import Foundation
import SafariServices

class U2FRequest {
    let appId : String
    let challenge : String
    let origin : String

    init?(info : [String : Any], origin : String) {
        self.origin = origin
        if let appId = info["appId"] as? String, let challenge = info["challenge"] as? String {
            self.appId = appId
            self.challenge = challenge
        } else {
            return nil
        }
    }

    static func ParseRequest(name : String, info : [String : Any]?, properties : SFSafariPageProperties?) throws -> U2FRequest {
        var request : U2FRequest?

        if let scheme = properties?.url?.scheme, let host = properties?.url?.host {
            let origin = scheme + "://" + host
            if let info = info {
                switch name {
                case U2FSignMessage:
                    request = U2FSignRequest(info:info, origin:origin)

                case U2FRegisterMessage:
                    request = U2FRegisterRequest(info:info, origin:origin)

                default:
                    break
                }

            }
        } else {
            throw U2FError.unknown(in: "bad origin")
        }

        guard request != nil else {
            throw U2FError.badRequest()
        }

        return request!
    }

    func ChallengeDictionary() -> [String:String] {
        return ["challenge": self.challenge, "version": U2F_V2, "appId": self.appId]
    }

    func Challenge() throws -> String  {
        let dict = self.ChallengeDictionary()
        let bytes = try JSONSerialization.data(withJSONObject:dict)
        let challenge = String.init(data:bytes, encoding: .utf8)!
        return challenge
    }

    func Perform(device : U2FDevice) throws -> String {
        throw U2FError.unknown(in: "abstract method should have been implemented")
    }
}

class U2FRegisterRequest : U2FRequest {
    override func Perform(device : U2FDevice) throws -> String {
        let challenge = try self.Challenge()
        return try device.Register(challenge: challenge, origin: self.origin)
    }
}

class U2FSignRequest : U2FRequest {
    let keyHandle : String

    override init?(info : [String : Any], origin: String) {
        if let keyHandle = info["keyHandle"] as? String {
            self.keyHandle = keyHandle
            super.init(info: info, origin: origin)
        } else {
            return nil
        }
    }

    override func ChallengeDictionary() -> [String:String] {
        var dict = super.ChallengeDictionary()
        dict["keyHandle"] = self.keyHandle
        return dict
    }

    override func Perform(device : U2FDevice) throws -> String {
        let challenge = try self.Challenge()
        return try device.Sign(challenge: challenge, origin: self.origin)
    }
    
}
