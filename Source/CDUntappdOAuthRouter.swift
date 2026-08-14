//
//  CDUntappdOAuthRouter.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/8/17.
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

import Foundation

/// Routes for Untappd OAuth endpoints.
///
/// Used internally to construct HTTP requests for OAuth authentication.
public enum CDUntappdOAuthRouter {

    /// The OAuth authorization endpoint.
    case authorize(parameters: Parameters)

    var path: String {
        switch self {
        case .authorize:
            "authorize"
        }
    }

    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: CDUntappdURL.oAuth) else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }
        switch self {
        case let .authorize(parameters):
            return try CDUntappdParameterEncoding.urlRequest(
                for: url.appendingPathComponent(path),
                parameters: parameters
            )
        }
    }
}
