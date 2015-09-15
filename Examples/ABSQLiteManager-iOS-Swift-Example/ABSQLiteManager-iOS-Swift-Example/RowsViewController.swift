//
//  RowsViewController.swift
//  ABSQLiteManager-iOS-Swift-Example
//
//  Copyright (c) 2015 Kristaps Zeibarts.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class RowsViewController: UITableViewController {

    var rows:[Dictionary<String, AnyObject>] = []
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let row = self.rows[indexPath.row]
        var components: [String] = []
        if let firstName = (row["first_name"] as? String) {
            components.append(firstName)
        }
        if let lastName = (row["last_name"] as? String) {
            components.append(lastName)
        }
        cell.textLabel?.text = components.joinWithSeparator(" ")
        
        if let birthYear = (row["birth_year"] as? Int) {
            cell.detailTextLabel?.text = "Born: " + String(birthYear)
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
}
