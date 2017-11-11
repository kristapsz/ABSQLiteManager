//
//  ABSQLiteReader.m
//  ABSQLiteManager
//
//  Created by Kristaps Zeibarts on 19.01.10.
//  Copyright (c) 2010 Kristaps Zeibarts.
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

#import <sqlite3.h>

#import "ABSQLiteReader.h"

@interface ABSQLiteReader ()

@property (nonatomic, strong) NSString *path;
@property (nonatomic) sqlite3 *connection;

@end

@implementation ABSQLiteReader

- (instancetype _Nonnull)initWithDatabasePath:(NSString * _Nonnull)path {
    self = [super init];
    if (self) {
        self.path = path;
    }
    return self;
}

- (sqlite3 *)connection {
    if (!_connection) {
        if (sqlite3_open([self.path UTF8String], &_connection) == SQLITE_OK) {
            // Database was opened
        } else {
            return nil;
        }
    }
    return _connection;
}

- (void)dealloc {
    if (_connection) { // Close database, if opened.
        sqlite3_close(_connection);
    }
}

#pragma mark - Database Strucutre

- (NSArray * _Nonnull)tables {
    NSArray *objects = [self fetchRowsFromTable:@"sqlite_master" columns:@[@"name"] predicate:[NSPredicate predicateWithFormat:@"type='table'"] error:nil];
    NSMutableArray *output = [NSMutableArray new];
    for (NSDictionary *object in objects) {
        [output addObject:[object valueForKey:@"name"]];
    }
    return output;
}

- (NSArray * _Nullable)structureOfTable:(NSString * _Nonnull)tableName {
    NSString *query = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    return [self fetchRowsWithQuery:query error:nil];
}

- (NSArray * _Nullable)columnsForTable:(NSString * _Nullable)tableName {
    NSMutableArray *output = [NSMutableArray new];
    NSArray *objects = [self structureOfTable:tableName];
    for (NSDictionary *object in objects) {
        NSString *name = [object objectForKey:@"name"];
        [output addObject:name];
    }
    return output;
}

#pragma mark - Counting rows

- (NSInteger)numberOfRowsInTable:(NSString * _Nonnull)table error:(NSError * _Nullable * _Nullable)error {
    return [self numberOfRowsInTable:table predicate:nil error:error];
}

- (NSInteger)numberOfRowsInTable:(NSString * _Nonnull)table predicate:(NSPredicate * _Nullable)predicate error:(NSError * _Nullable * _Nullable)error {
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT COUNT(*) AS count FROM %@", table];
    if (predicate) {
        [query appendFormat:@" WHERE %@", predicate.predicateFormat];
    }
    NSArray *rows = [self fetchRowsWithQuery:query error:error];
    if ((error && *error) || rows.count!=1) {
        return -1;
    }
    NSDictionary *row = rows[0];
    return [row[@"count"] integerValue];
}

- (NSInteger)numberOfRowsForQuery:(NSString * _Nonnull)query error:(NSError * _Nullable * _Nullable)error {
    NSString *countQuery = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM (%@)", query];
    NSArray *rows = [self fetchRowsWithQuery:countQuery error:error];
    if ((error && *error) || rows.count!=1) {
        return -1;
    }
    return [rows[0][@"count"] integerValue];
}

#pragma mark - Fetching Rows

- (NSArray * _Nullable)fetchRowsWithQuery:(NSString * _Nonnull)query error:(NSError * _Nullable * _Nullable)error {
    if (!self.connection) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Database cannot be opened."]};
            *error = [NSError errorWithDomain:@"ABSQLiteManager"
                                         code:100
                                     userInfo:userInfo];
        }
        return nil;
    }
#ifdef DEBUG
    printf("%s\n", query.UTF8String);
#endif
    NSMutableArray *objects=[NSMutableArray new]; // storage for fetched objects
    
    sqlite3_stmt *selectstmt; // select statement
    if(sqlite3_prepare_v2(self.connection, [query UTF8String], -1, &selectstmt, NULL) == SQLITE_OK) {
        NSMutableArray *columns = [NSMutableArray new]; // storage for column names
        int columnsCount = sqlite3_column_count(selectstmt); // getting column count
        for (int i=0; i<columnsCount; i++) { // reading names of columns
            NSString *name = [NSString stringWithCString:(char *)sqlite3_column_name(selectstmt, (int)i) encoding:NSUTF8StringEncoding];
            [columns addObject:name];
        }
        @autoreleasepool {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) { // executing query and looping through rows
                NSMutableDictionary *object = [NSMutableDictionary new];
                [columns enumerateObjectsUsingBlock:^(NSString *column, NSUInteger idx, BOOL *stop) { // reading all columns
                    if (sqlite3_column_type(selectstmt, (int)idx) == SQLITE_INTEGER) {// integer
                        int value = sqlite3_column_int(selectstmt, (int)idx);
                        [object setValue:@(value) forKey:column];
                    } else if (sqlite3_column_type(selectstmt, (int)idx) == SQLITE_FLOAT) { // float
                        double value = sqlite3_column_double(selectstmt, (int)idx);
                        [object setValue:@(value) forKey:column];
                    } else if (sqlite3_column_type(selectstmt, (int)idx) == SQLITE_TEXT) { // text
                        char * chars = (char *)sqlite3_column_text(selectstmt, (int)idx);
                        NSString *value = [NSString stringWithUTF8String:chars];
                        [object setValue:value forKey:column];
                    } else if (sqlite3_column_type(selectstmt, (int)idx) == SQLITE_BLOB) { // blob
                        const unsigned char *bytes = sqlite3_column_blob(selectstmt, (int)idx);
                        NSUInteger length = sqlite3_column_bytes(selectstmt, (int)idx);
                        NSData *data = [NSData dataWithBytes:bytes length:length];
                        [object setValue:data forKey:column];
                    }
                }];
                [objects addObject:object];
            }
        }
    } else {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Query execution failed: %@", query]};
            *error = [NSError errorWithDomain:@"ABSQLiteManager"
                                         code:101
                                     userInfo:userInfo];
        }
        return nil;
    }
    sqlite3_finalize(selectstmt);
    
    return objects;
}

- (NSArray * _Nullable)fetchRowsFromTable:(NSString * _Nonnull)tableName columns:(NSArray * _Nullable)columns predicate:(NSPredicate * _Nullable)predicte error:(NSError * _Nullable * _Nullable)error {
    // building the query
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"SELECT "];
    if (columns.count>0) { // joins column names with comma
        [query appendString:[columns componentsJoinedByString:@", "]];
    } else {
        [query appendString:@"*"];
    }
    [query appendFormat:@" FROM %@", tableName];
    if (predicte) { // adding where statement
        [query appendString:@" WHERE "];
        [query appendString:predicte.predicateFormat];
    }
    return [self fetchRowsWithQuery:query error:error];
}

- (NSDictionary * _Nonnull)fetchAllTables {
    NSArray *tables = [self tables]; // getting list of all tables
    NSMutableDictionary *output = [NSMutableDictionary new];
    for (NSString *table in tables) {
        NSError *error = nil;
        NSArray *objects = [self fetchRowsFromTable:table columns:nil predicate:nil error:&error];
        if (!error) {
            [output setObject:objects forKey:table];
        }
    }
    return output;
}

@end
