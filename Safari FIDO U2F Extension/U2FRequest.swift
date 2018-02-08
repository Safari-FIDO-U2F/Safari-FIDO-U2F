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
import SafariServices

class U2FRequest {
    typealias U2FRequestDictionary = [String:Any]
    
    let appId : String
    let registeredKeys : [String]
    let origin : String
    let requestId : Int
    let timeout : Int?
    var responseType : String { get { return "unknown" } }

    init?(requestDictionary : U2FRequestDictionary, origin : String) {
        self.origin = origin
        if
            let appId = requestDictionary["appId"] as? String,
            let keys = requestDictionary["registeredKeys"] as? [String],
            let requestId = requestDictionary["requestId"] as? Int {
                self.appId = appId
                self.registeredKeys = keys
                self.requestId = requestId
                self.timeout = requestDictionary["timeout"] as? Int
        } else {
            return nil
        }
    }
    
    /**
        Parse a request dictionary, and attempt to create and return a request object.
     */
    
    static func parse(type : String, requestDictionary : U2FRequestDictionary, properties : SFSafariPageProperties?) throws -> U2FRequest {
        let origin : String
        if let scheme = properties?.url?.scheme, let host = properties?.url?.host {
            origin = scheme + "://" + host
        } else {
            origin = "https://unknown"
        }

        var request : U2FRequest?
        switch type {
        case U2FSignRequest.RequestType:
            request = U2FSignRequest(requestDictionary: requestDictionary, origin:origin)

        case U2FRegisterRequest.RequestType:
            request = U2FRegisterRequest(requestDictionary: requestDictionary, origin:origin)

        default:
            break
        }

        guard request != nil else {
            throw U2FError.badRequest()
        }

        return request!
    }

    func run(device : U2FDevice) throws -> U2FResponse.Dictionary {
        throw U2FError.unknown(in: "abstract method should have been implemented")
    }
}

