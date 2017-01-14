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
        page.dispatchMessageToScript(withName: "response", userInfo: userinfo)
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            
            // userInfo must contains following keys:
            //   appId: string
            //   challenge: string
            // if messageName == "sign":
            //   keyHandle: string
            
            let appId = userInfo?["appId"] as? String
            let challenge = userInfo?["challenge"] as? String
            let keyHandle = userInfo?["keyHandle"] as? String
            
            guard appId != nil && challenge != nil && (messageName != "sign" || keyHandle != nil) else {
                self._sendResponse(page: page, error: U2FError.badrequest(), result: nil)
                return
            }
            
            guard properties?.url?.scheme != nil && properties?.url?.host != nil else {
                self._sendResponse(page: page, error: U2FError.unknown(in: "get_origin"), result: nil)
                return
            }
            let origin = properties!.url!.scheme! + "://" + properties!.url!.host!
            
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
                if messageName == "register" {
                    let chal_bytes = try JSONSerialization.data(withJSONObject: ["challenge": challenge!, "version": U2F_V2, "appId": appId!])
                    let chal = String.init(data: chal_bytes, encoding: .utf8)!
                    ret = u2fh_register(devs!, chal, origin, &response, U2FH_REQUEST_USER_PRESENCE)
                } else if messageName == "sign" {
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
    }

}
