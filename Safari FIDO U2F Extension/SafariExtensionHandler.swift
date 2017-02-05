//
//  SafariExtensionHandler.swift
//  Safari FIDO U2F Extension
//
//  Created by Yikai Zhao on 10/13/16.
//  Copyright © 2016 Yikai Zhao. All rights reserved.
//

import SafariServices

enum U2FError: Error {
    case unknown(in: String)
    case badrequest()
    case error(u2fh_rc, in: String)
}

let U2FSignMessage = "U2FSign"
let U2FRegisterMessage = "U2FRegister"
let U2FResponseMessage = "U2FResponse"

let U2F_V2 = "U2F_V2"
let U2F_NODEVICE_RETRY_COUNT = 10

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

    func ProcessResponse(result : u2fh_rc, response : UnsafeMutablePointer<Int8>) throws -> String {
        guard result == U2FH_OK else {
            throw U2FError.error(result, in: "Bad response.")
        }

        guard let _ = response else {
            throw U2FError.unknown(in: "Bad response.")
        }

        return String.init(cString: response!)
    }

    func Register(challenge : String, origin : String) throws -> String {
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_register(self.device, challenge, origin, &response, U2FH_REQUEST_USER_PRESENCE)
        return ProcessResponse(ret, response)
    }

    func Sign(challenge : String, origin : String) throws -> String {
        var response: UnsafeMutablePointer<Int8>? = nil
        let ret = u2fh_authenticate(devs!, chal, origin, &response, U2FH_REQUEST_USER_PRESENCE)
        return ProcessResponse(ret, response)
    }
}


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
                }
            }
        } else {
            throw U2FError.unknown(in: "bad origin")
        }

        guard request != nil else {
            throw U2FError.badrequest()
        }

        return request!
    }

    func ChallengeDictionary() -> [String:String] {
        return ["challenge": self.challenge, "version": U2F_V2, "appId": self.appId]
    }

    func Challenge() -> String {
        let dict = self.ChallengeDictionary()
        let bytes = try JSONSerialization.data(withJSONObject:dict)
        let challenge = String.init(data:bytes, encoding: .utf8)!
        return challenge
    }

    func Perform(device : U2FDevice) -> String {

    }
}

class U2FRegisterRequest : U2FRequest {
    override func Perform(device : U2FDevice) {
        let challenge = self.Challenge()
        device.Register(challenge, self.origin)
    }
}

class U2FSignRequest : U2FRequest {
    let keyHandle : String

    override init?(info : [String : Any], origin: String) {
        if let keyHandle = info["keyHandle"] as? String {
            self.keyHandle = keyHandle
        } else {
            return nil
        }
    }

    override func ChallengeDictionary() -> [String:String] {
        var dict = super.ChallengeDictionary()
        dict["keyHandle"] = self.keyHandle
        return dict
    }

    override func Perform(device : U2FDevice) {
        let challenge = self.Challenge()
        device.Sign(challenge, self.origin)
    }

}


class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func sendResponse(page: SFSafariPage, response: String) {
        var userinfo = [ "result" : response]
        page.dispatchMessageToScript(withName: U2FResponseMessage, userInfo: userinfo)
    }

    func sendError(page: SFSafariPage, error: U2FError) {
        var userinfo: [String: Any] = [:]
        switch error {
        case U2FError.unknown(let pos):
            userinfo["error"] = "Unknown Error in \(pos)"
        case U2FError.error(let errcode, let pos):
            let errmsg = String.init(cString: u2fh_strerror(errcode.rawValue))
            userinfo["error"] = "Error in \(pos): \(errmsg)"
        case U2FError.badrequest():
            userinfo["error"] = "Bad Request"
        }
        page.dispatchMessageToScript(withName: U2FResponseMessage, userInfo: userinfo)
    }


    /**
     Process a message from the content script.
     
     We construct a request based on the name of the message.
     We then make a new device
     We attempt to construct
     */

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").

        page.getPropertiesWithCompletionHandler { properties in
            do {
                let request = U2FSignRequest.ParseRequest(name: messageName, info:userInfo, properties:properties)
                let device = U2FDevice()
                let response = request.Perform(device: device)
                self._sendResponse(page: page, error: nil, result: response_s)
            } catch let error as U2FError {
                self.sendError(page: page, error: error)
            } catch {
                self.sendError(page: page, error: U2FError.unknown(in: "messageReceived"))
            }
        }
    }

}
