//
//  U2FError.swift
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

enum U2FErrorCode : Int {
    case OK = 0
    case OTHER_ERROR = 1
    case BAD_REQUEST = 2
    case CONFICONFIGURATION_UNSUPPORTED = 3
    case DEVICE_INELIGIBLE = 4
    case TIMEOUT = 5
}

enum U2FError: Error {
    case missingInfo
    case missingRequestId
    case unknownRequestType(type: String)
    case badRequest(reason: String)
    case error(u2fh_rc, in: String)
    case unknown(in: String)

    func errorDescription() -> [String:Any] {
        let description : [String: Any]
        switch self {
        case .unknown(let pos):
            description = ["errorMessage" : "Unknown Error: \(pos)", "errorCode" : U2FErrorCode.OTHER_ERROR]
            
        case .missingInfo:
            description = ["errorMessage" : "missing info dictionary", "errorCode" : U2FErrorCode.BAD_REQUEST]
            
        case .missingRequestId:
            description = ["errorMessage" : "missing request id", "errorCode" : U2FErrorCode.BAD_REQUEST]
            
        case .unknownRequestType(let type):
            description = ["errorMessage" : "unknown request type: \(type)", "errorCode" : U2FErrorCode.BAD_REQUEST]

        case .error(let errcode, let pos):
            let errmsg = String.init(cString: u2fh_strerror(errcode.rawValue))
            description = ["errorMessage": "Error in \(pos): \(errmsg)", "errorCode" : errcode]
            
        case .badRequest(let reason):
            description = ["errorMessage": "Bad Request: \(reason)", "errorCode" : U2FErrorCode.OTHER_ERROR]
        }
        
        return description
    }
}


