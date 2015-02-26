//
//  TableViewController.m
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

#import "RowsViewController.h"

@interface RowsViewController ()

@end

@implementation RowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Persons";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *row = self.rows[indexPath.row];
    // Join first_name and last_name with space
    NSMutableArray *components = [NSMutableArray new];
    NSString *firstName = [row valueForKey:@"first_name"];
    if (firstName)
        [components addObject:firstName];
    NSString *lastName = [row valueForKey:@"last_name"];
    if (lastName)
        [components addObject:lastName];
    cell.textLabel.text = [components componentsJoinedByString:@" "];
    NSNumber *birthYear = [row valueForKey:@"birth_year"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Born: %@", birthYear];
    return cell;
}

@end
