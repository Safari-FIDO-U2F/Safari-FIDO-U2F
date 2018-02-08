//
//  U2FDevice.swift
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

class U2FDevice {
    let device : OpaquePointer

    init() throws {
        var ret = u2fh_global_init(U2FH_DEBUG)
        guard ret == U2FH_OK else {
            throw U2FError.error(ret, in: "Global Init")
        }

        var returnedDevice: OpaquePointer?
        ret = u2fh_devs_init(&returnedDevice)
        guard ret == U2FH_OK else {
            throw U2FError.error(ret, in: "Device Init")
        }

        guard let device = returnedDevice else {
            throw U2FError.unknown(in: "Device Init")
        }

        for _ in 0..<U2F_NODEVICE_RETRY_COUNT {
            ret = u2fh_devs_discover(device, nil)
            if ret == U2FH_OK {
                break
            }
            Thread.sleep(forTimeInterval: 1.0)
        }

        guard ret == U2FH_OK else {
            throw U2FError.error(ret, in: "Device Discover")
        }

        self.device = device
    }

    deinit {
        u2fh_devs_done(self.device)
        u2fh_global_done()
    }

    private func encodeRequest(request : Any) throws -> String {
        let jsonBytes = try JSONSerialization.data(withJSONObject:request)
        guard let jsonString = String.init(data:jsonBytes, encoding: .utf8) else {
            throw U2FError.unknown(in: "Couldn't encode request")
        }
        
        return jsonString
    }
    
    private func processResponse(result : u2fh_rc, response : UnsafeMutablePointer<Int8>?) throws -> U2FResponse.Dictionary {
        guard result == U2FH_OK else {
            throw U2FError.error(result, in: "Bad response.")
        }

        guard response != nil else {
            throw U2FError.unknown(in: "Bad response.")
        }

        let json = String.init(cString: response!)
        guard let data = json.data(using: String.Encoding.utf8) else {
            throw U2FError.unknown(in: "Bad response.")
        }
        
        guard let parsed = try JSONSerialization.jsonObject(with:data, options: .allowFragments) as? U2FResponse.Dictionary else {
            throw U2FError.unknown(in: "Bad response.")
        }
        
        return parsed
    }

    func perform(request : U2FRequest) throws -> U2FResponse {
        let responseData = try request.run(device: self)
        return U2FResponse(type: request.responseType, requestId : request.requestId, responseData : response)
    }
    
    func register(request : U2FRequest.U2FRequestDictionary, origin : String) throws -> U2FResponse.Dictionary {
        print("register: \(request) \(origin)")

        let jsonRequest = try encodeRequest(request: request)
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_register(self.device, jsonRequest, origin, &response, U2FH_REQUEST_USER_PRESENCE)

        return try processResponse(result: ret, response: response)
    }

    func sign(challenge : String, origin : String) throws -> U2FResponse.Dictionary {
        print("sign: \(challenge) \(origin)")

        let jsonRequest = try encodeRequest(request: challenge)
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_authenticate(device, jsonRequest, origin, &response, U2FH_REQUEST_USER_PRESENCE)

        return try processResponse(result: ret, response: response)
    }
}

