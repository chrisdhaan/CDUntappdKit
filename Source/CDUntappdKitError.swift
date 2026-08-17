//
//  CDUntappdKitError.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
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

/// Errors thrown by CDUntappdKit.
public enum CDUntappdKitError: Error, Sendable {
    /// The request could not be constructed (e.g. an invalid URL from route parameters).
    case invalidRequest(underlying: any Error & Sendable)
    /// A transport-level failure occurred (no connection, timed out, etc).
    case networkFailure(underlying: any Error & Sendable)
    /// The API returned a non-2xx HTTP status code.
    case httpError(statusCode: Int, data: Data)
    /// The response body could not be decoded into the expected type.
    case decodingFailed(underlying: any Error & Sendable)
    /// The API returned a 2xx response whose body describes an application-level error.
    case apiError(String)
    /// A required precondition (e.g. a non-empty OAuth client ID or authorization code) wasn't met, or a write/action
    /// endpoint was called without an active access token, so no request was sent.
    case invalidCredentials(String)
}
