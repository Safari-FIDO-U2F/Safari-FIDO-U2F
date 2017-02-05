//
//  U2FError.swift
//  Safari FIDO U2F
//
//  Created by Sam Deane on 05/02/2017.
//  Copyright © 2017 Yikai Zhao. All rights reserved.
//

import Foundation

enum U2FError: Error {
    case unknown(in: String)
    case badrequest()
    case error(u2fh_rc, in: String)
}

