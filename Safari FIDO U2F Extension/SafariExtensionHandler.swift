//
//  SafariExtensionHandler.swift
//  Safari FIDO U2F Extension
//
//  Created by Yikai Zhao on 10/13/16.
//  Copyright © 2016 Yikai Zhao. All rights reserved.
//

import SafariServices

let U2FSignMessage = "U2FSign"
let U2FRegisterMessage = "U2FRegister"
let U2FResponseMessage = "U2FResponse"

let U2F_V2 = "U2F_V2"
let U2F_NODEVICE_RETRY_COUNT = 10




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
