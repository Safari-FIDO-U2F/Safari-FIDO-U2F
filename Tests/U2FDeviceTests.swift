//  ----------------------------------------------------------------
//  Created by Sam Deane on 08/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import XCTest

let testAppIdQuoted = "https:\\/\\/demo.yubico.com"
let testRegistrationData = "BQR_5ng1-yI6hc6x20RVjMYuHJTyp6biyrzl5yT0V4-0d4ywEQgGAXMUcnI07l1Gv2Kf9qgnK1zlHFz6Y0zjGxq5UPo27WMf_SCHTQHMQN-jN3WArnk47oOrmy7NYl41QbVeGPXLCGYzHs_WnlWoRbt7DyZTVDyfsEsfH0zeFbm3Y6Sl3VAhnDjd2f2zSsXhufmNMIIBVTCB_aADAgECAgqWcVVHVVeAljgVMAoGCCqGSM49BAMCMBcxFTATBgNVBAMTDEZUIEZJRE8gMDEwMDAeFw0xNDA4MTQxODI5MzJaFw0yNDA4MTQxODI5MzJaMDExLzAtBgNVBAMTJlUyRiBTZWN1cml0eSBLZXktLTk2NzE1NTQ3NTU1NzgwOTYzODE1MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE89DW0e8xFP_goJ2H3EVKu94kukiBXs0qww2jXZLAdsafSEPFRHoFP0JLhWykVgpEjnJ3dm_vqsFih4wPg1pj7qMXMBUwEwYLKwYBBAGC5RwCAQEEBAMCBSAwCgYIKoZIzj0EAwIDRwAwRAIgUKY-UEhLxxArC4Mj7ZzpIUvix7aY33TGCh6ZhAvhgPQCIARqXiMcOpGWdao7qfBju7D9LJqljYTSACYRvD1a8WmFMEQCIE7CDjf7Ap-Mzx2FQyIQeqNETiTtXmICFWCHE8ITr6rRAiBKMaOugkOOIakLD-9GLQIC-jPVfqC4pmDcvK4xf1XPZw"
let testClientData = "eyAiY2hhbGxlbmdlIjogIkVlZlJrWGc2UTZIaEdwVTI4U1NCYmpVX0FsNmV6VDV6V1dvNmd3R0prQVkiLCAib3JpZ2luIjogImh0dHA6XC9cL3Rlc3Qub3JpZ2luIiwgInR5cCI6ICJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIgfQ"
let testRegisterChallenge = "{\"challenge\":\"\(testChallenge)\",\"version\":\"U2F_V2\",\"appId\":\"\(testAppIdQuoted)\"}"
let testRegisterResponse = "{ \"registrationData\": \"\(testRegistrationData)\", \"clientData\": \"\(testClientData)\" }"


/*
//{ "registrationData": "BQRS5WoiK81XnxobZWjuqyB6n0uRxOlNCu5HoRjyffizRGF7tFLxyDQs8AKihZPX54moLBVczL16bH-SReG7K4d8UPxePQQLLC0ARa9AjeOZJTzbwpvSgjsvoFbluIYEl8Dc_B0wAXr2KKWWwNHCLy3CZjAjsZZS9ZdPTJkLvnY8m644-daE11NieCtzEqyhvtMAMIIBVTCB_aADAgECAgqWcVVHVVeAljgVMAoGCCqGSM49BAMCMBcxFTATBgNVBAMTDEZUIEZJRE8gMDEwMDAeFw0xNDA4MTQxODI5MzJaFw0yNDA4MTQxODI5MzJaMDExLzAtBgNVBAMTJlUyRiBTZWN1cml0eSBLZXktLTk2NzE1NTQ3NTU1NzgwOTYzODE1MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE89DW0e8xFP_goJ2H3EVKu94kukiBXs0qww2jXZLAdsafSEPFRHoFP0JLhWykVgpEjnJ3dm_vqsFih4wPg1pj7qMXMBUwEwYLKwYBBAGC5RwCAQEEBAMCBSAwCgYIKoZIzj0EAwIDRwAwRAIgUKY-UEhLxxArC4Mj7ZzpIUvix7aY33TGCh6ZhAvhgPQCIARqXiMcOpGWdao7qfBju7D9LJqljYTSACYRvD1a8WmFMEUCIQD6mKVRVWPwEyH5tKH3o_2xh7PeIKHgBahtu-KoGNgT-gIgSafuXHpphvMkeBUO60bCKmxTq3iFH5Bz3qjFbJ7WDPM", "clientData": "eyAiY2hhbGxlbmdlIjogIktCcGV4NWRvZnZtUWJ4dWdPWVI4S3NWMS03VncxYnRQcm0yZHdKV0FQcnMiLCAib3JpZ2luIjogImh0dHBzOlwvXC9kZW1vLnl1Ymljby5jb20iLCAidHlwIjogIm5hdmlnYXRvci5pZC5maW5pc2hFbnJvbGxtZW50IiB9" }let signChallenge = "{\"version\":\"U2F_V2\",\"challenge\":\"ZR-2IyxSFTSoQ00GOMN6hrQC5qmXXoDyG7PmwYYWUTw\",\"keyHandle\":\"oea6fGi-MGzyGGrJzb2LFdvCm9KCOy-gVuW4hgSXwNz7koDuZcnP7X4K9MK5DX2wwxud_QRqjmuWhIqGIYhUta5g6f36_b_QO1hzvBO8vb8\",\"appId\":\"https://demo.yubico.com\"}"
*/

let testSignatureData = "AQAAABcwRgIhAPpHzFHIVZRGlSJvOJ452d3Cbxd00pObjwKZVbWfHt7PAiEArliUes968d98oTENLS-BC1Vkwrxw59yb5Q0KLTtM6hE"
let testSignChallenge = "{\"version\":\"U2F_V2\",\"challenge\":\"\(testChallenge)\",\"keyHandle\":\"\(testKeyHandle)\",\"appId\":\"\(testAppIdQuoted)\"}"
let testSignResponse = "{ \"signatureData\": \"\(testSignatureData)\", \"clientData\": \"\(testClientData)\", \"keyHandle\": \"\(testKeyHandle)\" }"

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
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
            let device = try MockDevice(response: testRegisterResponse)
            let _ = try device.perform(request: request)
            XCTAssertEqual(device.request, testRegisterChallenge)
        } catch {
            XCTFail()
        }
    }

    func testRegistrationResponseData() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
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

        } catch {
            XCTFail()
        }
        
    }

    func testSigningChallenge() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
            let device = try MockDevice(response: testSignResponse)
            let _ = try device.perform(request: request)

            XCTAssertEqual(device.request, testSignChallenge)
        } catch {
            XCTFail()
        }
        
    }

    func testSigningResponse() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOrigin) else {
            XCTFail()
            return
        }
        
        do {
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
            
        } catch {
            XCTFail()
        }
        
    }

}
