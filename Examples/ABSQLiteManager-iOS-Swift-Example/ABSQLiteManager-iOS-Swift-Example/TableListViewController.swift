//
//  TableListViewController.swift
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
import ABSQLiteManager

class TableListViewController: UITableViewController {

    var objectReader: ABSQLiteReader
    var tables: [String]
    
    
    required init(coder aDecoder: NSCoder) {
        let path = NSBundle.mainBundle().pathForResource("ABSQLReader", ofType: "sqlite")
        self.objectReader = ABSQLiteReader(databasePath: path)
        self.tables = self.objectReader.tables() as [String]
        super.init(coder: aDecoder)
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tables.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let table = self.tables[indexPath.row]
        cell.textLabel?.text = "Table: " + table
        let rowsCount = self.objectReader.numberOfRowsInTable(table, error: nil)
        cell.detailTextLabel?.text = "Rows: " + String(rowsCount)
        return cell;
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailController = segue.destinationViewController as RowsViewController
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            // Getting table name for selected row
            let table = self.tables[indexPath.row]
            // Fetching all rows from the table
            let rows = self.objectReader.fetchRowsFromTable(table, columns: nil, predicate: nil, error: nil) as [Dictionary<String, AnyObject>]
            detailController.rows = rows
        }
    }
}

