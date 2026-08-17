//
//  ViewController.swift
//  iOS Example
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

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

}

// MARK: - UITableViewDataSource Methods

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDUntappdEndpointCell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.backgroundColor = UIColor.untappdYellow()
            cell.textLabel?.text = "user/info/{username}"
            cell.textLabel?.textColor = UIColor.white
        case 1:
            cell.backgroundColor = UIColor.untappdBrown()
            cell.textLabel?.text = "user/wishlist/{username}"
            cell.textLabel?.textColor = UIColor.white
        case 2:
            cell.backgroundColor = UIColor.untappdYellow()
            cell.textLabel?.text = "user/friends/{username}"
            cell.textLabel?.textColor = UIColor.white
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Untappd API Endpoints"
        default:
            return ""
        }
    }
}

// MARK: - UITableView Delegate Methods

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserInfo(forUsername: "DehaanSolo",
                                                                                                compact: false)
                    if let user = response.user {
                        print(user)
                    }
                } catch {
                    print("Error fetching user info: \(error.localizedDescription)")
                }
            }
        case 1:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserWishList(forUsername: "DehaanSolo",
                                                                                                    offset: 0,
                                                                                                    limit: 10,
                                                                                                    sort: .highestABV)
                    if let wishList = response.wishList {
                        print(wishList)
                    }
                } catch {
                    print("Error fetching wish list: \(error.localizedDescription)")
                }
            }
        case 2:
            Task {
                do {
                    let response = try await CDUntappdKitManager.shared.apiClient.fetchUserFriends(forUsername: "DehaanSolo",
                                                                                                   offset: 0,
                                                                                                   limit: 10)
                    if let friends = response.friends {
                        print(friends)
                    }
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
