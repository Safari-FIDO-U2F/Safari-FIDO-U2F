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

    func ProcessResponse(result : u2fh_rc, response : UnsafeMutablePointer<Int8>?) throws -> String {
        guard result == U2FH_OK else {
            throw U2FError.error(result, in: "Bad response.")
        }

        guard response != nil else {
            throw U2FError.unknown(in: "Bad response.")
        }

        return String.init(cString: response!)
    }

    func Register(challenge : String, origin : String) throws -> String {
        print("register: \(challenge) \(origin)")
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_register(self.device, challenge, origin, &response, U2FH_REQUEST_USER_PRESENCE)

        return try ProcessResponse(result: ret, response: response)
    }

    func Sign(challenge : String, origin : String) throws -> String {
        print("sign: \(challenge) \(origin)")
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_authenticate(device, challenge, origin, &response, U2FH_REQUEST_USER_PRESENCE)

        return try ProcessResponse(result: ret, response: response)
    }
}

