//  ----------------------------------------------------------------
//  Created by Sam Deane on 08/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import XCTest

let testRegistrationData = "BQR_5ng1-yI6hc6x20RVjMYuHJTyp6biyrzl5yT0V4-0d4ywEQgGAXMUcnI07l1Gv2Kf9qgnK1zlHFz6Y0zjGxq5UPo27WMf_SCHTQHMQN-jN3WArnk47oOrmy7NYl41QbVeGPXLCGYzHs_WnlWoRbt7DyZTVDyfsEsfH0zeFbm3Y6Sl3VAhnDjd2f2zSsXhufmNMIIBVTCB_aADAgECAgqWcVVHVVeAljgVMAoGCCqGSM49BAMCMBcxFTATBgNVBAMTDEZUIEZJRE8gMDEwMDAeFw0xNDA4MTQxODI5MzJaFw0yNDA4MTQxODI5MzJaMDExLzAtBgNVBAMTJlUyRiBTZWN1cml0eSBLZXktLTk2NzE1NTQ3NTU1NzgwOTYzODE1MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE89DW0e8xFP_goJ2H3EVKu94kukiBXs0qww2jXZLAdsafSEPFRHoFP0JLhWykVgpEjnJ3dm_vqsFih4wPg1pj7qMXMBUwEwYLKwYBBAGC5RwCAQEEBAMCBSAwCgYIKoZIzj0EAwIDRwAwRAIgUKY-UEhLxxArC4Mj7ZzpIUvix7aY33TGCh6ZhAvhgPQCIARqXiMcOpGWdao7qfBju7D9LJqljYTSACYRvD1a8WmFMEQCIE7CDjf7Ap-Mzx2FQyIQeqNETiTtXmICFWCHE8ITr6rRAiBKMaOugkOOIakLD-9GLQIC-jPVfqC4pmDcvK4xf1XPZw"
let testClientData = "eyAiY2hhbGxlbmdlIjogIkVlZlJrWGc2UTZIaEdwVTI4U1NCYmpVX0FsNmV6VDV6V1dvNmd3R0prQVkiLCAib3JpZ2luIjogImh0dHA6XC9cL3Rlc3Qub3JpZ2luIiwgInR5cCI6ICJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIgfQ"
let testRegisterResponse = "{ \"registrationData\": \"\(testRegistrationData)\", \"clientData\": \"\(testClientData)\" }"

class MockDevice : U2FDevice {
    override func register_(jsonRequest: String, origin: String) throws -> String {
        return testRegisterResponse
    }
}

class U2FDeviceTests: XCTestCase {

    func testRegister() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
            let device = try MockDevice()
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

        } catch {
            XCTFail()
        }
        
    }

    func testSign() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
            let device = try U2FDevice()
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
            
        } catch {
            XCTFail()
        }
        
    }

}
