//
//  ViewController.swift
//  Safari FIDO U2F
//
//  Created by Yikai Zhao on 10/13/16.
//
//  ----------------------------------------------------------------
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Cocoa
import SafariServices

let EXT_ID = "com.blahgeek.Safari-FIDO-U2F.Safari-FIDO-U2F-Extension"
let HOMEPAGE = "https://github.com/blahgeek/Safari-FIDO-U2F"

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let link = NSMutableAttributedString.init(string: HOMEPAGE)
        link.addAttribute(NSAttributedStringKey.link, value: HOMEPAGE, range: NSRange.init(location: 0, length: link.length))
        self.hyperlinkField.attributedStringValue = link;
        self.updateExtensionStatus(self.extensionUpdateBtn)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBOutlet weak var hyperlinkField: NSTextField!
    @IBOutlet weak var extensionUpdateBtn: NSButton!
    @IBOutlet weak var extensionStatusLabel: NSTextField!
    
    @IBAction func updateExtensionStatus(_ sender: NSButton) {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: EXT_ID) { (state, error) in
            print("extension: \(state!)")
            if error != nil {
                print("Error determining the state of extension: \(error!)");
                return;
            }
            
            DispatchQueue.main.async {
                if state!.isEnabled {
                    self.extensionStatusLabel.stringValue = "Enabled"
                } else {
                    self.extensionStatusLabel.stringValue = "Disabled"
                }
            }

        }
    }

    @IBAction func enableSafariExtension(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: EXT_ID) { (_) in
            self.updateExtensionStatus(self.extensionUpdateBtn)
        }
    }

}

