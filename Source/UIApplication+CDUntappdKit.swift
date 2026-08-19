//
//  UIApplication+CDUntappdKit.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/9/17.
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

#if os(iOS) || os(visionOS)
    import UIKit

    internal extension UIApplication {

        @available(iOSApplicationExtension, unavailable)
        class func topViewController(_ base: UIViewController? = {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                let window = scene.windows.first(where: { $0.isKeyWindow })
            else { return nil }
            return window.rootViewController
        }()) -> UIViewController? {

            if let navigationController = base as? UINavigationController {
                return topViewController(navigationController.visibleViewController)
            }

            if let tabController = base as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(selected)
                }
            }

            if let presented = base?.presentedViewController {
                return topViewController(presented)
            }

            return base
        }
    }
#endif
