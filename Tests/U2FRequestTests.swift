//  ----------------------------------------------------------------
//  Created by Sam Deane on 08/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import XCTest


class tests: XCTestCase {
    func assertThrowsU2FError(_ block : () throws -> () ) -> U2FError? {
        do {
            try block()
            XCTFail("should have thrown")
        } catch let error as U2FError {
            return error
        } catch {
            XCTFail("wrong error thrown")
        }
        
        return nil
    }
    
    
    func testRegisterRequestParsing() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }

        XCTAssertEqual(request.appId, testAppId)
        XCTAssertEqual(request.origin, testOriginString)
        XCTAssertEqual(request.requestId, testRequestId)
        XCTAssertEqual(request.registeredKeys.count, 0)
        XCTAssertEqual(request.responseType, U2FRegisterRequest.ResponseType)
    }

    func testSignRequestParsing() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOriginURL) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(request.appId, testAppId)
        XCTAssertEqual(request.origin, testOriginString)
        XCTAssertEqual(request.requestId, testRequestId)
        XCTAssertEqual(request.responseType, U2FSignRequest.ResponseType)
        XCTAssertEqual(request.registeredKeys.count, 1)
        let registeredKey = request.registeredKeys[0]
        XCTAssertEqual(registeredKey["version"] as? String, testRegisteredKey["version"] as? String)
        XCTAssertEqual(registeredKey["keyHandle"] as? String, testRegisteredKey["keyHandle"] as? String)
        XCTAssertEqual(request.challenge, testChallenge)
    }

    func testRequestParsing() {
        XCTAssertNotNil(try U2FRequest.parse(type:U2FRegisterRequest.RequestType, requestDictionary:testRegisterRequest, url:testOriginURL) as? U2FRegisterRequest)
        XCTAssertNotNil(try U2FRequest.parse(type:U2FSignRequest.RequestType, requestDictionary:testSignRequest, url:testOriginURL) as? U2FSignRequest)
    }
    
    func testUnknownType() {
        if let error = assertThrowsU2FError({ let _ = try U2FRequest.parse(type:"unknown", requestDictionary:[:], url:testOriginURL) }) {
            switch error {
            case .unknownRequestType(let type):
                XCTAssertEqual(type, "unknown")
                
            default:
                XCTFail("wrong error type")
            }
        }
    }
    
    func testMalformedRegisterRequest() {
        if let error = assertThrowsU2FError({ let _ = try U2FRequest.parse(type:U2FRegisterRequest.RequestType, requestDictionary:[:], url:testOriginURL) }) {
            switch error {
            case .unparseableRequest:
                break
                
            default:
                XCTFail("wrong error type")
            }
        }
    }

    func testMalformedSignRequest() {
        if let error = assertThrowsU2FError({ let _ = try U2FRequest.parse(type:U2FSignRequest.RequestType, requestDictionary:[:], url:testOriginURL) }) {
            switch error {
            case .unparseableRequest:
                break
                
            default:
                XCTFail("wrong error type")
            }
        }
    }

}
