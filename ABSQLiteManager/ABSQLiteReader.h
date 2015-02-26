//
//  ABSQLiteReader.h
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

#import <Foundation/Foundation.h>

@interface ABSQLiteReader : NSObject

/**
 *  Returns a reader for a SQLite 3 database located at the specified path. This is the designated initializer.
 *
 *  @param path Path to the SQLite 3 database file. Can't be nil.
 *
 *  @return A reader for the given SQLite 3 database.
 */
- (instancetype)initWithDatabasePath:(NSString*)path;

# pragma mark - Database Structure

/**
 *  Use this method to get a list of all tables in the current database.
 *
 *  @return Array of table names as strings.
 */
- (NSArray*)tables;

/**
 *  Use this method to get the structure of a table.
 *
 *  @param tableName Name of a table.
 *
 *  @return Array of dictionaries with column information by executing query "PRAGMA table_info(tableName)"
 */
- (NSArray*)structureOfTable:(NSString*)tableName;

/**
 *  Use this method to get a list of all columns in the given table.
 *
 *  @param tableName Name of a table
 *
 *  @return Array of column names as strings.
 */
- (NSArray*)columnsForTable:(NSString*)tableName;

# pragma mark - Number of Rows

/**
 *  Use this method to get a total number of rows in a table.
 *
 *  @param table Name of the table.
 *  @param error Error, if occured.
 *
 *  @return Number of rows in the given table.
 */
- (NSInteger)numberOfRowsInTable:(NSString*)table error:(NSError**)error;

/**
 *  Use this method to get a number of rows in a table by using predicate.
 *
 *  @param table Name of the table.
 *  @param predicate Predicate to be used.
 *  @param error Error, if occured.
 *
 *  @return Number of rows in the given table with predicate.
 */
- (NSInteger)numberOfRowsInTable:(NSString*)table predicate:(NSPredicate*)predicate error:(NSError**)error;

/**
 *  Use this method to get a number of rows for given query.
 *
 *  @param query A valid SQLite 3 query.
 *  @param error Error, if occured.
 *
 *  @return Number of rows for given query.
 */
- (NSInteger)numberOfRowsForQuery:(NSString*)query error:(NSError**)error;

# pragma mark - Fetching rows

/**
 *  Use this method to load contents of a query into memory.
 *  Returns an array of objects where objects are dictionaries with column names as keys and column content as values.
 *  @param query A valid SQLite 3 query.
 *  @param error Error, if occured.
 *
 *  @return Array of fetched objects.
 */
- (NSArray*)fetchRowsWithQuery:(NSString*)query error:(NSError**)error;

/**
 *  Use this method to load contents of a table into memory.
 *  Returns an array of objects where objects are dictionaries with column names as keys and column content as values.
 *
 *  @param tableName Name of the table.
 *  @param columns   Array of column names. If empty array or nil then selects all columns.
 *  @param predicte  Simple predicate. Can be nil.
 *  @param error     Error, if occured.
 *
 *  @return Array of fetched objects.
 */
- (NSArray*)fetchRowsFromTable:(NSString*)tableName columns:(NSArray*)columns predicate:(NSPredicate*)predicte error:(NSError**)error;

/**
 *  Use this method to load all contents of the database in a dictionary.
 *  Use it only for small databases that can fit into the memory.
 *
 *  Example output: {"table_a":[
 *                              {"col_1": "value_a", "col_2": "value_b"},
 *                              {"col_1": "value_c", "col_2": "value_d"}
 *                             ]
 *                   }
 *  @return Dictionary with table names as keys and rows as an array of dictionaries.
 */
- (NSDictionary*)fetchAllTables;

@end
