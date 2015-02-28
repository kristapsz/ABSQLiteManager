//
//  ViewController.m
//  ABSQLiteManager-iOS-Example
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

#import "TableListViewController.h"
#import "RowsViewController.h"

@import ABSQLiteManager;

@interface TableListViewController ()

@property (nonatomic, strong) NSArray *tables;
@property (nonatomic, strong) ABSQLiteReader *objectReader;

@end

@implementation TableListViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Path to the existing SQLite database
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ABSQLReader" ofType:@"sqlite"];
    // Initialize object reader with SQLite database at given path.
    self.objectReader = [[ABSQLiteReader alloc] initWithDatabasePath:path];
    // Read and store table names
    self.tables = [self.objectReader tables];

    self.title = @"List of Tables";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate and Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // getting current table
    NSString *table = self.tables[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Table: %@", table];
    // getting number of rows in the table
    NSInteger rowsCount = [self.objectReader numberOfRowsInTable:table error:nil];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Rows: %@", @(rowsCount)];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RowsViewController *detailController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    // Getting table name for selected row
    NSString *table = self.tables[indexPath.row];
    // Getting all rows from the table
    NSArray *rows = [self.objectReader fetchRowsFromTable:table columns:nil predicate:nil error:nil];
    detailController.rows = rows;
}

@end
