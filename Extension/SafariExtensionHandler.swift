//
//  SafariExtensionHandler.swift
//  Safari FIDO U2F Extension
//
//  Created by Yikai Zhao on 10/13/16.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import SafariServices

let U2F_V2 = "U2F_V2"

let U2FErrorResponse = "u2f_error_response"
let DefaultOrigin = URL(string: "https://default.origin")!

class SafariExtensionHandler: SFSafariExtensionHandler {
    

    /**
     Process a message from the content script.
    
     The request dictionary should contain enough information to create a request object.
     We then make a device object, and ask it to perform the request, which gives us back a response.
     We send the response back as a message.
     
     If anything goes wrong along the way, a U2FError is thrown. We catch these and turn them into error responses.
     */

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        guard let requestDictionary = userInfo, let requestId = requestDictionary["requestId"] as? Int else {
            self.sendError(U2FError.badRequest(), toPage: page)
            return
        }

        page.getPropertiesWithCompletionHandler { properties in
            do {
                print("\(messageName)\n\(userInfo!)")
                let request = try U2FRequest.parse(type: messageName, requestDictionary: requestDictionary, url: properties?.url ?? DefaultOrigin)
                let device = try U2FDevice()
                let response = try device.perform(request: request)
                response.sendTo(page: page)
            } catch let error as U2FError {
                self.sendError(error, toPage: page, requestId: requestId)
            } catch {
                self.sendError(U2FError.unknown(in: "messageReceived"), toPage: page, requestId: requestId)
            }
        }
    }
    
    func sendError(_ error: U2FError, toPage page: SFSafariPage, requestId : Int = 0) {
        var responseData: [String: Any] = [:]
        switch error {
        case U2FError.unknown(let pos):
            responseData["errorMessage"] = "Unknown Error: \(pos)"
            
        case U2FError.error(let errcode, let pos):
            let errmsg = String.init(cString: u2fh_strerror(errcode.rawValue))
            responseData["errorCode"] = errcode
            responseData["errorMessage"] = "Error in \(pos): \(errmsg)"

        case U2FError.badRequest():
            responseData["errorMessage"] = "Bad Request"
            responseData["errorCode"] = 2
        }

        let response = U2FResponse(type: U2FErrorResponse, requestId: requestId, responseData: responseData)
        response.sendTo(page: page)
    }
    


}


/*
 
 testRegister = {"type":"u2f_register_request","appId":"https://demo.yubico.com","registeredKeys":[],"timeoutSeconds":30,"requestId":1,"registerRequests":[{"version":"U2F_V2","challenge":"EefRkXg6Q6HhGpU28SSBbjU_Al6ezT5zWWo6gwGJkAY"}]}
 
 testChallenge = {"type":"u2f_sign_request","appId":"http://demo.yubico.com","registeredKeys":[{"version":"U2F_V2","keyHandle":"VoJjU-7HNBC1_oiHwGc-95TjoHdeGIexHExlXG4nA0D62lvSAFSJdLkmE2LrwNHAuOBlLb0ijZ52Ie-ykHZVlA"}],"timeoutSeconds":30,"requestId":1,"challenge":"P5GB3YFGHmtccXKanP6G9xOXl10e6n5gIqTxNc2WcfI"}
 */

 
 
