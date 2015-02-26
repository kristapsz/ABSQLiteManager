//
//  ABSQLiteManagerTests.m
//  ABSQLiteManagerTests
//
//  Created by Kristaps Zeibarts on 19.01.12.
//  Copyright (c) 2012 Kristaps Zeibarts.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@import ABSQLiteManager;

@interface ABSQLiteManagerTests : XCTestCase

@property (nonatomic, strong) ABSQLiteReader *objectReader;

@end

@implementation ABSQLiteManagerTests

- (void)setUp {
    [super setUp];
    self.objectReader = [[ABSQLiteReader alloc] initWithDatabasePath:[self databasePath]];
}

- (void)tearDown {
    [super tearDown];
}

- (NSString*)databasePath {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ABSQLReader" ofType:@"sqlite"];
    return path;
}

- (void)testThatTestDatabaseExists {
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self databasePath] isDirectory:nil]);
}

#pragma mark - Testing Getting Database Structure

- (void)testListTables {
    NSArray *tables = [self.objectReader tables];
    XCTAssertTrue(tables.count==1);
    XCTAssertEqualObjects(tables[0], @"persons");
}

- (void)testListColumns {
    NSArray *columns = [self.objectReader columnsForTable:@"persons"];
    XCTAssertEqual(columns.count, 6);
    NSArray *testColumns = @[@"id", @"first_name", @"last_name", @"birth_year", @"photo", @"children"];
    XCTAssertTrue([columns isEqualToArray:testColumns]);
}

#pragma mark - Testing Fetching Rows

- (void)testQuery {
    NSString *query = @"SELECT first_name, last_name, birth_year FROM persons where first_name='Carl'";
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsWithQuery:query error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 1);
    NSDictionary *object = objects[0];
    XCTAssertTrue([object[@"first_name"] isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(object[@"first_name"], @"Carl");
    XCTAssertTrue([object[@"last_name"] isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(object[@"last_name"], @"Linnaeus");
    XCTAssertTrue([object[@"birth_year"] isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(object[@"birth_year"], @1707);
}

- (void)testFailingQuery {
    // There is no column named "name" in the persons table
    NSString *query = @"SELECT name FROM persons where first_name='Charles'";
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsWithQuery:query error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(objects);
}

- (void)testEmptyResultsQuery {
    NSString *query = @"SELECT first_name, last_name, birth_year FROM persons where first_name='Charles'";
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsWithQuery:query error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(objects);
    XCTAssertEqual(objects.count, 0);
}

- (void)testSelectAllFieldsQuery {
    NSString *query = @"SELECT * FROM persons";
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsWithQuery:query error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 2);
}

- (void)testListObjectsForAllColumnsInTable {
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:nil predicate:nil error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 2);
}

- (void)testRowContentDataTypes {
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:nil predicate:nil error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 2);
    XCTAssertTrue([objects[0] isKindOfClass:[NSDictionary class]]);
    NSDictionary *object = objects[0];
    XCTAssertTrue([object[@"id"] isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(object[@"id"], @1);
    XCTAssertTrue([object[@"first_name"] isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(object[@"first_name"], @"John");
    XCTAssertTrue([object[@"last_name"] isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(object[@"last_name"], @"Chapman");
    XCTAssertTrue([object[@"birth_year"] isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(object[@"birth_year"], @1774);
    XCTAssertTrue([object[@"children"] isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(object[@"children"], @10);
    XCTAssertTrue([object[@"photo"] isKindOfClass:[NSData class]]);
    // comparing if the photo data from databases matches the data from file
    NSData *photoData = object[@"photo"];
    NSString *photoPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"John_Chapman" ofType:@"jpg"];
    NSData *testPhotoData = [NSData dataWithContentsOfFile:photoPath];
    XCTAssertEqualObjects(photoData, testPhotoData);
}

- (void)testListObjectsForNonExistingTable {
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"companies" columns:nil predicate:nil error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(objects, );
}

- (void)testFetchUsingSimplePredicate {
    NSError *error = nil;
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:@[] predicate:[NSPredicate predicateWithFormat:@"first_name=%@", @"John"] error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 1);
}

- (void)testFetchUsingFailingPredicate {
    NSError *error = nil;
    // there is no field named "address"
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:@[] predicate:[NSPredicate predicateWithFormat:@"address=%@", @"Berlin"] error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(objects);
}

- (void)testFetchUsingSimpleAndCompoundPredicate {
    NSError *error = nil;
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"first_name=%@", @"John"];
    NSPredicate *childrenPredicate = [NSPredicate predicateWithFormat:@"children>%@", @5];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[childrenPredicate, namePredicate]];
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:@[] predicate:predicate error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 1);
}

- (void)testFetchUsingSimpleOrCompoundPredicate {
    NSError *error = nil;
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"first_name=%@", @"John"];
    NSPredicate *childrenPredicate = [NSPredicate predicateWithFormat:@"children>%@", @20];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[childrenPredicate, namePredicate]];
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:@[] predicate:predicate error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(objects.count, 2);
}

- (void)testFetchUsingSimpleCompoundPredicateWithNoResults {
    NSError *error = nil;
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"first_name=%@", @"John"];
    NSPredicate *childrenPredicate = [NSPredicate predicateWithFormat:@"children>%@", @20];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[childrenPredicate, namePredicate]];
    NSArray *objects = [self.objectReader fetchRowsFromTable:@"persons" columns:@[] predicate:predicate error:&error];
    XCTAssertEqual(objects.count, 0);
}

- (void)testFetchingAllTables {
    NSDictionary *databaseContents = [self.objectReader fetchAllTables];
    XCTAssertEqual(databaseContents.allKeys.count, 1);
    XCTAssertNotNil(databaseContents[@"persons"]);
    NSArray *persons = databaseContents[@"persons"];
    XCTAssertEqual(persons.count, 2);
}

#pragma mark - Testing Number of Rows

- (void)testNumberOfRowsForQuery {
    NSError *error = nil;
    NSInteger count = [self.objectReader numberOfRowsForQuery:@"SELECT * FROM persons" error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(count, 2);
}

- (void)testFailingNumberOfRowsForQuery {
    NSError *error = nil;
    NSInteger count = [self.objectReader numberOfRowsForQuery:@"SELECT address FROM persons" error:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(count, -1);
}

- (void)testNumberOfRowsForTable {
    NSError *error = nil;
    NSInteger count = [self.objectReader numberOfRowsInTable:@"persons" error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(count, 2);
}

- (void)testNumberOfRowsInTableWithPredicate {
    NSError *error = nil;
    NSInteger count = [self.objectReader numberOfRowsInTable:@"persons" predicate:[NSPredicate predicateWithFormat:@"first_name=%@", @"John"] error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(count, 1);
}

@end
