//  ----------------------------------------------------------------
//  Created by Sam Deane on 05/02/2017.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation


class U2FDevice {
    static let VERSION = "U2F_V2"
    static let RETRY_COUNT = 10

    let device : OpaquePointer

    init() throws {
        var ret = u2fh_global_init(U2FH_DEBUG)
        guard ret == U2FH_OK else {
            throw U2FError.error(ret, action: "u2fh_global_init")
        }

        var returnedDevice: OpaquePointer?
        ret = u2fh_devs_init(&returnedDevice)
        guard ret == U2FH_OK else {
            throw U2FError.error(ret, action: "u2fh_devs_init")
        }

        guard let device = returnedDevice else {
            throw U2FError.unknown(in: "no device returned")
        }

        for _ in 0 ..< U2FDevice.RETRY_COUNT {
            ret = u2fh_devs_discover(device, nil)
            if ret == U2FH_OK {
                break
            }
            Thread.sleep(forTimeInterval: 1.0)
        }

        guard ret == U2FH_OK else {
            throw U2FError.error(ret, action: "u2fh_devs_discover")
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
    
    private func decodeResponse(result : u2fh_rc, response : UnsafeMutablePointer<Int8>?) throws -> String {
        guard result == U2FH_OK else {
            throw U2FError.error(result, action: "decoding response")
        }

        guard response != nil else {
            throw U2FError.unknown(in: "no response data")
        }

        let json = String.init(cString: response!)
        return json
    }
    
    private func decodeResponse(json: String) throws -> U2FResponse.Dictionary {
        guard let data = json.data(using: String.Encoding.ascii) else {
            throw U2FError.unknown(in: "response couldn't be decoded")
        }
        
        guard let parsed = try JSONSerialization.jsonObject(with:data, options: .allowFragments) as? U2FResponse.Dictionary else {
            throw U2FError.unknown(in: "response wasn't a dictionary")
        }

        return parsed
    }

    internal func register_(jsonRequest : String, origin : String) throws -> String {
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_register(device, jsonRequest, origin, &response, U2FH_REQUEST_USER_PRESENCE)
        return try decodeResponse(result: ret, response: response)
    }

    internal func sign_(jsonRequest : String, origin : String) throws -> String {
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_authenticate(device, jsonRequest, origin, &response, U2FH_REQUEST_USER_PRESENCE)
        return try decodeResponse(result: ret, response: response)
    }
    
    func perform(request : U2FRequest) throws -> U2FResponse {
        let responseData = try request.run(device: self)
        return U2FResponse(type: request.responseType, requestId : request.requestId, responseData : responseData)
    }
    
    func register(request : U2FRequest.Dictionary, origin : String) throws -> U2FResponse.Dictionary {
        print("register: \(request) \(origin)")

        let jsonRequest = try encodeRequest(request: request)
        let jsonResponse = try register_(jsonRequest: jsonRequest, origin: origin)
        return try decodeResponse(json: jsonResponse)
    }

    public func sign(request : U2FRequest.Dictionary, origin : String) throws -> U2FResponse.Dictionary {
        print("sign: \(request) \(origin)")

        let jsonRequest = try encodeRequest(request: request)
        let jsonResponse = try sign_(jsonRequest: jsonRequest, origin: origin)
        return try decodeResponse(json: jsonResponse)
    }
}

