//
//  U2FError.swift
//  Safari FIDO U2F
//
//  Created by Sam Deane on 05/02/2017.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

enum U2FError: Error {
    case unknown(in: String)
    case badRequest()
    case error(u2fh_rc, in: String)
}

