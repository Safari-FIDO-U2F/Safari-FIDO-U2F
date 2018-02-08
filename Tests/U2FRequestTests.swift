//
//  tests.swift
//  tests
//
//  Created by Sam Deane on 08/02/2018.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import XCTest

let testOriginString = "http://test.origin"
let testOrigin = URL(string: testOriginString)!

let testAppId = "https://demo.yubico.com"

let testTimeout = 30

let testRequestId = 123

let testRegisteredKey : U2FRequest.Dictionary = [
    "version":"U2F_V2",
    "keyHandle":"VoJjU-7HNBC1_oiHwGc-95TjoHdeGIexHExlXG4nA0D62lvSAFSJdLkmE2LrwNHAuOBlLb0ijZ52Ie-ykHZVlA"
]

let testChallenge = "P5GB3YFGHmtccXKanP6G9xOXl10e6n5gIqTxNc2WcfI"

let testRegisterRequest : U2FRequest.Dictionary = [
    "type" : U2FRegisterRequest.RequestType,
    "appId" : testAppId,
    "timeoutSeconds" : testTimeout,
    "requestId" : testRequestId,
    "registeredKeys" : [],
    "registerRequests" : [
        ["version" : "U2F_V2", "challenge" : "EefRkXg6Q6HhGpU28SSBbjU_Al6ezT5zWWo6gwGJkAY"]
    ]
]

let testSignRequest : U2FRequest.Dictionary = [
    "type": U2FSignRequest.RequestType,
    "appId": testAppId,
    "timeoutSeconds":testTimeout,
    "requestId": testRequestId,
    "registeredKeys": [testRegisteredKey],
    "challenge": testChallenge
]

class tests: XCTestCase {
    
    func testRegisterRequestParsing() {
        guard let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOrigin) else {
            XCTFail()
            return
        }

        XCTAssertEqual(request.appId, testAppId)
        XCTAssertEqual(request.origin, testOriginString)
        XCTAssertEqual(request.requestId, testRequestId)
        XCTAssertNil(request.registeredKey)
        XCTAssertEqual(request.responseType, U2FRegisterRequest.ResponseType)
    }

    func testSignRequestParsing() {
        guard let request = U2FSignRequest(requestDictionary: testSignRequest, origin: testOrigin), let registeredKey = request.registeredKey else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(request.appId, testAppId)
        XCTAssertEqual(request.origin, testOriginString)
        XCTAssertEqual(request.requestId, testRequestId)
        XCTAssertEqual(request.responseType, U2FSignRequest.ResponseType)
        XCTAssertEqual(registeredKey["version"] as? String, testRegisteredKey["version"] as? String)
        XCTAssertEqual(registeredKey["keyHandle"] as? String, testRegisteredKey["keyHandle"] as? String)
        XCTAssertEqual(request.challenge, testChallenge)
    }

    func testRequestParsing() {
        XCTAssertNotNil(try U2FRequest.parse(type:U2FRegisterRequest.RequestType, requestDictionary:testRegisterRequest, url:testOrigin) as? U2FRegisterRequest)
        XCTAssertNotNil(try U2FRequest.parse(type:U2FSignRequest.RequestType, requestDictionary:testSignRequest, url:testOrigin) as? U2FSignRequest)
    }
    
    func testUnknownType() {
        do {
            let _ = try U2FRequest.parse(type:"unknown", requestDictionary:[:], url:testOrigin)
            XCTFail("should have thrown")
        } catch let error as U2FError {
            switch error {
            case .unknownRequestType(let type):
                XCTAssertEqual(type, "unknown")
                
            default:
                XCTFail("wrong error type")
            }
        } catch {
            XCTFail("wrong error thrown")
        }

    }
}
