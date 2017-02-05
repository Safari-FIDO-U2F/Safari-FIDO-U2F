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

let U2F_V2 = "U2F_V2"
let U2F_NODEVICE_RETRY_COUNT = 10

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
                case "U2FSign":
                    request = U2FSignRequest(info:info, origin:origin)

                case "U2FRegister":
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
        return
    }
}

class U2FRegisterRequest : U2FRequest {
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

}


class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func _sendResponse(page: SFSafariPage, error: U2FError?, result: String?) {
        var userinfo: [String: Any] = [:]
        if let error = error {
            switch error {
            case U2FError.unknown(let pos):
                userinfo["error"] = "Unknown Error in \(pos)"
            case U2FError.error(let errcode, let pos):
                let errmsg = String.init(cString: u2fh_strerror(errcode.rawValue))
                userinfo["error"] = "Error in \(pos): \(errmsg)"
            case U2FError.badrequest():
                userinfo["error"] = "Bad Request"
            }
        }
        if let result = result {
            userinfo["result"] = result
        }
        page.dispatchMessageToScript(withName: "U2FResponse", userInfo: userinfo)
    }
    
    func processRequest(request : U2FRequest, from page: SFSafariPage) {
            
            var ret: u2fh_rc
            var devs: OpaquePointer?
            do {
                ret = u2fh_global_init(U2FH_DEBUG)
                guard ret == U2FH_OK else {
                    throw U2FError.error(ret, in: "Global Init")
                }
                
                ret = u2fh_devs_init(&devs)
                guard ret == U2FH_OK else {
                    throw U2FError.error(ret, in: "Device Init")
                }
                guard let _ = devs else {
                    throw U2FError.unknown(in: "Device Init")
                }
                
                for _ in 0..<U2F_NODEVICE_RETRY_COUNT {
                    ret = u2fh_devs_discover(devs!, nil)
                    if ret == U2FH_OK {
                        break
                    }
                    Thread.sleep(forTimeInterval: 1.0)
                }
                guard ret == U2FH_OK else {
                    throw U2FError.error(ret, in: "Device Discover")
                }
                
                var response: UnsafeMutablePointer<Int8>? = nil
            if messageName == "U2FRegister" {
                    let chal_bytes = try JSONSerialization.data(withJSONObject: ["challenge": challenge!, "version": U2F_V2, "appId": appId!])
                    let chal = String.init(data: chal_bytes, encoding: .utf8)!
                    ret = u2fh_register(devs!, chal, origin, &response, U2FH_REQUEST_USER_PRESENCE)
            } else if messageName == "U2FSign" {
                    let chal_bytes = try JSONSerialization.data(withJSONObject: ["challenge": challenge!, "version": U2F_V2, "appId": appId!, "keyHandle": keyHandle!])
                    let chal = String.init(data: chal_bytes, encoding: .utf8)!
                    ret = u2fh_authenticate(devs!, chal, origin, &response, U2FH_REQUEST_USER_PRESENCE)
                }
                
                guard ret == U2FH_OK else {
                    throw U2FError.error(ret, in: messageName)
                }
                guard let _ = response else {
                    throw U2FError.unknown(in: messageName)
                }
                
                let response_s = String.init(cString: response!)
                self._sendResponse(page: page, error: nil, result: response_s)
                
            } catch let error as U2FError {
                self._sendResponse(page: page, error: error, result: nil)
            } catch {
                self._sendResponse(page: page, error: U2FError.unknown(in: "unknown"), result: nil)
            }
            
            if let devs = devs {
                u2fh_devs_done(devs)
            }
            u2fh_global_done()
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").

        page.getPropertiesWithCompletionHandler { properties in
            do {

                let request = U2FSignRequest.ParseRequest(name: messageName, info:userInfo, properties:properties)
                processRequest(request: request, from:page)

            } catch let error as U2FError {

                self._sendResponse(page: page, error: error, result: nil)

            } catch {

                self._sendResponse(page: page, error: U2FError.unknown(in: "unknown"), result: nil)
            }
        }
    }

}
