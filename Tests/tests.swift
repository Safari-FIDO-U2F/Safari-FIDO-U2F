//
//  tests.swift
//  tests
//
//  Created by Sam Deane on 08/02/2018.
//  Copyright © 2018 Safari FIDO U2F. All rights reserved.
//

import XCTest

let testOriginString = "http://test.origin"
let testOrigin = URL(string: testOriginString)!

let testAppId = "https://demo.yubico.com"

let testTimeout = 30

let testRequestId = 123

let testRegisterRequest : [String:Any] = [
    "type" : "u2f_register_request",
    "appId" : testAppId,
    "timeoutSeconds" : testTimeout,
    "requestId" : testRequestId,
    "registeredKeys" : [],
    "registerRequests" : [
        ["version" : "U2F_V2", "challenge" : "EefRkXg6Q6HhGpU28SSBbjU_Al6ezT5zWWo6gwGJkAY"]
    ]
]

let testChallengeRequest : [String:Any] = [
    "type": "u2f_sign_request",
    "appId": testAppId,
    "timeoutSeconds":testTimeout,
    "requestId": testRequestId,
    "registeredKeys":[
        ["version":"U2F_V2","keyHandle":"VoJjU-7HNBC1_oiHwGc-95TjoHdeGIexHExlXG4nA0D62lvSAFSJdLkmE2LrwNHAuOBlLb0ijZ52Ie-ykHZVlA"]
    ],
    "challenge":"P5GB3YFGHmtccXKanP6G9xOXl10e6n5gIqTxNc2WcfI"
]

class tests: XCTestCase {
    
    func testRegisterRequestParsing() {
        let request = U2FRegisterRequest(requestDictionary: testRegisterRequest, origin: testOrigin)
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.appId, testAppId)
        XCTAssertEqual(request?.origin, testOriginString)
        XCTAssertEqual(request?.requestId, testRequestId)
        XCTAssertNil(request?.registeredKey)
    }
    
}
