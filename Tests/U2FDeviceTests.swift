//  ----------------------------------------------------------------
//  Created by Sam Deane on 08/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import XCTest

class MockDevice : U2FDevice {
    let response : String
    var request = ""
    
    init(response : String) throws {
        self.response = response
        try super.init()
    }
    
    override func register_(jsonRequest: String, origin: String) throws -> String {
        request = jsonRequest
        return response
    }

    override func sign_(jsonRequest: String, origin: String) throws -> String {
        request = jsonRequest
        return response
    }

}

class U2FDeviceTests: XCTestCase {

    func testRegistrationChallenge() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }
        
        XCTAssertNoThrow({
            let device = try MockDevice(response: testRegisterResponse)
            let _ = try device.perform(request: request)
            XCTAssertEqual(device.request, testRegisterChallenge)
        })
    }

    func testRegistrationResponseData() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }
        
        XCTAssertNoThrow({
            let device = try MockDevice(response: testRegisterResponse)
            let response = try device.perform(request: request)
            XCTAssertEqual(response.type, U2FRegisterRequest.ResponseType)
            XCTAssertEqual(response.requestId, request.requestId)
            
            let responseData = response.responseData as! [String:Any]

            guard let registrationData = responseData["registrationData"] as? String else {
                XCTFail()
                return
            }
            XCTAssertEqual(registrationData, testRegistrationData)

            guard let clientData = responseData["clientData"] as? String else {
                XCTFail()
                return
            }
            XCTAssertEqual(clientData, testClientData)
        })
        
    }

    func testSigningChallenge() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }
        
        XCTAssertNoThrow({
            let device = try MockDevice(response: testSignResponse)
            let _ = try device.perform(request: request)

            XCTAssertEqual(device.request, testSignChallenge)
        })
    }

    func testSigningResponse() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }
        
        XCTAssertNoThrow({
            let device = try MockDevice(response: testSignResponse)
            let response = try device.perform(request: request)
            XCTAssertEqual(response.type, U2FSignRequest.ResponseType)
            XCTAssertEqual(response.requestId, request.requestId)
            
            let responseData = response.responseData as! [String:Any]
            
            guard let keyHandle = responseData["keyHandle"] as? String else {
                XCTFail()
                return
            }
            XCTAssertEqual(keyHandle, testKeyHandle)
            
            guard let signatureData = responseData["signatureData"] as? String else {
                XCTFail()
                return
            }
            XCTAssertEqual(signatureData, testSignatureData)
        })
        
    }

}
