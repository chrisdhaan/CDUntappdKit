//
//  CDUntappdMetadata.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/21/17.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

public struct CDUntappdMetadata: Decodable {

    public var code: Int?
    public var details: String?
    public var type: String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case details = "error_detail"
        case type = "error_type"
    }

    public func description() -> String {
        var description = ""

        if let code = self.code {
            description += "Code \(code): "
        }
        if let type = self.type {
            description += "\(type) - "
        }
        if let details = self.details {
            description += "\(details)"
        }

        return description
    }

    public func hasError() -> Bool {
        if let code = self.code,
            code != 200 {
            return true
        } else {
            return false
        }
    }
}
