//
//  CDUntappdEventMonitor.swift
//  CDUntappdKit
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

/// Observes `CDUntappdAPIClient`/`CDUntappdOAuthClient` request and response events.
public protocol CDUntappdEventMonitor: AnyObject, Sendable {
    /// Called once per logical request, immediately before it is first sent.
    func requestDidStart(urlRequest: URLRequest)
    /// Called once per logical request, when it reaches a terminal outcome (success or a
    /// non-retried failure). `response` is `nil` for a request that failed before a response was
    /// received; check `error` to distinguish that from success.
    func requestDidComplete(urlRequest: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?)
    /// Called when a request will be retried after a recoverable failure.
    func requestWillRetry(urlRequest: URLRequest?, retryCount: Int)
}

public extension CDUntappdEventMonitor {
    func requestDidStart(urlRequest _: URLRequest) {}
    func requestDidComplete(urlRequest _: URLRequest?, response _: HTTPURLResponse?, data _: Data?, error _: Error?) {}
    func requestWillRetry(urlRequest _: URLRequest?, retryCount _: Int) {}
}
