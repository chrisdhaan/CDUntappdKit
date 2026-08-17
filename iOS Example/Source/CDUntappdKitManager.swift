//
//  CDUntappdKitManager.swift
//  iOS Example
//
//  Created by Christopher de Haan on 8/15/17.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CDUntappdKit
import UIKit

@MainActor
final class CDUntappdKitManager: NSObject {

    static let shared = CDUntappdKitManager()

    var apiClient: CDUntappdAPIClient!

    func configure() {
        // clientId/clientSecret are sourced from Secrets.xcconfig via Info.plist.
        // Copy Secrets.xcconfig.example to Secrets.xcconfig and fill in your own
        // Untappd API credentials before building this app.
        guard let clientId = Bundle.main.infoDictionary?["UNTAPPD_CLIENT_ID"] as? String,
              let clientSecret = Bundle.main.infoDictionary?["UNTAPPD_CLIENT_SECRET"] as? String else {
            fatalError("Missing UNTAPPD_CLIENT_ID / UNTAPPD_CLIENT_SECRET. Copy Secrets.xcconfig.example to Secrets.xcconfig and fill in your credentials.")
        }

        self.apiClient = CDUntappdAPIClient(clientId: clientId,
                                            clientSecret: clientSecret,
                                            redirectUrl: "https://www.untappd.com/")
    }
}
