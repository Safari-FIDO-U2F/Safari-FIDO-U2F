//  ----------------------------------------------------------------
//  Created by Sam Deane on 08/02/2018.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

/**
 A number of constants defining various bits of data to feed into the U2F class, or
 to validate output of the classes against.
 */

let testOriginString = "http://test.origin"
let testOriginURL = URL(string: testOriginString)!

let testAppHost = "demo.yubico.com"
let testAppId = "https://\(testAppHost)"
let testAppIdQuoted = "https:\\/\\/\(testAppHost)"

let testTimeout = 30

let testRequestId = 123

let testKeyHandle = "oea6fGi-MGzyGGrJzb2LFdvCm9KCOy-gVuW4hgSXwNz7koDuZcnP7X4K9MK5DX2wwxud_QRqjmuWhIqGIYhUta5g6f36_b_QO1hzvBO8vb8"

let testRegisteredKey : U2FRequest.Dictionary = [
    "version": U2FDevice.VERSION,
    "keyHandle": testKeyHandle
]

let testChallenge = "P5GB3YFGHmtccXKanP6G9xOXl10e6n5gIqTxNc2WcfI"

let testRegistrationData = "BQR_5ng1-yI6hc6x20RVjMYuHJTyp6biyrzl5yT0V4-0d4ywEQgGAXMUcnI07l1Gv2Kf9qgnK1zlHFz6Y0zjGxq5UPo27WMf_SCHTQHMQN-jN3WArnk47oOrmy7NYl41QbVeGPXLCGYzHs_WnlWoRbt7DyZTVDyfsEsfH0zeFbm3Y6Sl3VAhnDjd2f2zSsXhufmNMIIBVTCB_aADAgECAgqWcVVHVVeAljgVMAoGCCqGSM49BAMCMBcxFTATBgNVBAMTDEZUIEZJRE8gMDEwMDAeFw0xNDA4MTQxODI5MzJaFw0yNDA4MTQxODI5MzJaMDExLzAtBgNVBAMTJlUyRiBTZWN1cml0eSBLZXktLTk2NzE1NTQ3NTU1NzgwOTYzODE1MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE89DW0e8xFP_goJ2H3EVKu94kukiBXs0qww2jXZLAdsafSEPFRHoFP0JLhWykVgpEjnJ3dm_vqsFih4wPg1pj7qMXMBUwEwYLKwYBBAGC5RwCAQEEBAMCBSAwCgYIKoZIzj0EAwIDRwAwRAIgUKY-UEhLxxArC4Mj7ZzpIUvix7aY33TGCh6ZhAvhgPQCIARqXiMcOpGWdao7qfBju7D9LJqljYTSACYRvD1a8WmFMEQCIE7CDjf7Ap-Mzx2FQyIQeqNETiTtXmICFWCHE8ITr6rRAiBKMaOugkOOIakLD-9GLQIC-jPVfqC4pmDcvK4xf1XPZw"

let testClientData = "eyAiY2hhbGxlbmdlIjogIkVlZlJrWGc2UTZIaEdwVTI4U1NCYmpVX0FsNmV6VDV6V1dvNmd3R0prQVkiLCAib3JpZ2luIjogImh0dHA6XC9cL3Rlc3Qub3JpZ2luIiwgInR5cCI6ICJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIgfQ"

let testSignatureData = "AQAAABcwRgIhAPpHzFHIVZRGlSJvOJ452d3Cbxd00pObjwKZVbWfHt7PAiEArliUes968d98oTENLS-BC1Vkwrxw59yb5Q0KLTtM6hE"


/**
 An example registration request, in the form that would be sent to the extension by the JS bridge.
 */

let testRegisterRequest : U2FRequest.Dictionary = [
    "type" : U2FRegisterRequest.RequestType,
    "appId" : testAppId,
    "timeoutSeconds" : testTimeout,
    "requestId" : testRequestId,
    "registeredKeys" : [],
    "registerRequests" : [
        ["version" : U2FDevice.VERSION, "challenge" : testChallenge]
    ]
]


/**
 The JSON string that should be passed into u2fh_register, as a result of the test registration request
 */

let testRegisterChallenge = "{\"challenge\":\"\(testChallenge)\",\"version\":\"U2F_V2\",\"appId\":\"\(testAppIdQuoted)\"}"


/**
 The JSON response that should be returned by u2fh_register, as a result of the test registration request
 */

let testRegisterResponse = "{ \"registrationData\": \"\(testRegistrationData)\", \"clientData\": \"\(testClientData)\" }"

/// MARK - Signing

/**
 An example signing request, in the form that would be sent to the extension by the JS bridge.
 */

let testSignRequest : U2FRequest.Dictionary = [
    "type": U2FSignRequest.RequestType,
    "appId": testAppId,
    "timeoutSeconds":testTimeout,
    "requestId": testRequestId,
    "registeredKeys": [testRegisteredKey],
    "challenge": testChallenge
]

/**
 The JSON string that should be passed into u2fh_authorize, as a result of the test sign request
 */
let testSignChallenge = "{\"version\":\"U2F_V2\",\"challenge\":\"\(testChallenge)\",\"keyHandle\":\"\(testKeyHandle)\",\"appId\":\"\(testAppIdQuoted)\"}"

/**
 The JSON response that should be returned by u2fh_authorize, as a result of the test sign request
 */
let testSignResponse = "{ \"signatureData\": \"\(testSignatureData)\", \"clientData\": \"\(testClientData)\", \"keyHandle\": \"\(testKeyHandle)\" }"

