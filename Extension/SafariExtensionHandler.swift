//  ----------------------------------------------------------------
//  Created by Yikai Zhao on 10/13/16.
//
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import SafariServices


let U2FErrorResponse = "u2f_error_response"


let DefaultOrigin = URL(string: "https://default.origin")!

/**
 In debug only, we log out a bit of extra information to the console.
 */

func debug(_ message : String) {
    #if DEBUG
    NSLog(message)
    #endif
}

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    
    /**
     Process a message from the content script.
    
     The userInfo should contain keys corresponding to the [Javascript low level API](https://fidoalliance.org/specs/fido-u2f-v1.2-ps-20170411/fido-u2f-javascript-api-v1.2-ps-20170411.html#low-level-messageport-api).
     This should be enough information to create the appropriate U2FRequest object.
     We then make a U2FDevice object, and ask it to perform the request, which gives us back a U2FResponse.
     Finally we convert this back into a dictionary and send the response back to Safari as a message.
     
     If anything goes wrong along the way, a U2FError is thrown. We catch these and turn them into error responses.
     */

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        
        // if we don't have a userInfo dictionary, something is badly wrong
        guard let requestDictionary = userInfo else {
            self.sendError(U2FError.missingInfo, toPage: page)
            return
        }
        
        // we need to pass back a requestId key in order for the javascript side
        // to be able to look up the corresponding callback and call it
        guard let requestId = requestDictionary["requestId"] as? Int else {
            self.sendError(U2FError.missingRequestId, toPage: page)
            return
        }

        // we need the page properties in order to extract the origin from the page url
        page.getPropertiesWithCompletionHandler { properties in
            do {
                // I'm not quite sure under what circumstances the url can be missing
                // but for now we default to a dummy origin if so; this may be a security
                // issue, I'm not entirely sure at this point
                let origin = properties?.url ?? DefaultOrigin
                debug("\(messageName)\n\(origin)\n\(userInfo!)")
                
                // parse and execute the request
                let request = try U2FRequest.parse(type: messageName, requestDictionary: requestDictionary, url: origin)
                let device = try U2FDevice()
                let response = try device.perform(request: request)
                
                // send the response back to the page for processing on the javascript side
                debug("response \(response)")
                page.dispatchMessageToScript(withName: response.type, userInfo: response.info)
                
            } catch let error as U2FError {
                
                // we caught an error that we know about, so report it
                self.sendError(error, toPage: page, requestId: requestId)
                
            } catch {
                
                // something else went wrong
                // this is probably a json parsing error, but could be something else unexpected
                self.sendError(U2FError.unknown(in: "messageReceived"), toPage: page, requestId: requestId)
            }
        }
    }
    
    func sendError(_ error: U2FError, toPage page: SFSafariPage, requestId : Int = 0) {
        let response = U2FResponse(type: U2FErrorResponse, requestId: requestId, responseData: error.errorDescription())
        debug("error \(response.info)")
        page.dispatchMessageToScript(withName: response.type, userInfo: response.info)
    }
    


}

