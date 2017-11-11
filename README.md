## SQLite Reader

ABSQLiteManager is a lightweight SQLite reading library for iOS. It can be used to quickly convert SQLite database to Foundation objects.

It provides:

- Converting SQLite database to Foundation objects.
- Listing table structure
- Listing table names
- Listing column names
- Easily fetching rows from tables
- Easily fetching rows by using sql queries
- Support for NSPredicate
- Swift 4 support (by using ABSQLiteManager.Framework)

NOTE: Use it only with queries whose results can fit into the memory.

ABSQLiteManager was originally developed and used in the first versions of [NATURE MOBILE](https://www.naturemobile.org) apps between 2010 and 2012. After that it was replaced with Core Data.
This library sometimes still might be useful as a quick way to read sqlite files. The project is modernized to be compatible with ARC, AMR64 and Xcode 9. The v0.1 source files still should be compatible with any iOS SDK that supports ARC.


## How to use it
```objective-c
@import ABSQLiteManager;
...

NSString *path = ...
ABSQLiteReader *reader = [[ABSQLiteReader alloc] initWithDatabasePath:path];

// Getting all table names
NSArray *tables = [reader tables];

// Getting all column names for given table name
NSArray *columns = [reader columnsForTable:@"persons"];

// Fetching all rows from given table
NSArray *persons = [reader fetchRowsFromTable:@"persons" columns:nil predicate:nil error:NULL];

// Fetching rows using predicate
NSPredicate *predicate = [NSPredicate predicateWithFormat:@"first_name = %@", @"John"];
NSArray *somePersons = [reader fetchRowsFromTable:@"table_name" columns:@[@"last_name", @"birth_year"] predicate:predicate error:NULL];

// Fetching rows by using query
NSArray *allPersons = [reader fetchRowsWithQuery:@"SELECT * FROM persons" error:NULL];
```

## Installation

There are two ways to use ABSQLiteManager in your project:

- Copy all the files into your project (Objective-C only)
- Import the ABSQLiteManager project as a Cocoa Touch Framework (Objective-C and Swift)

### Copy all the files into your project (Objective-C only)

- Copy ABSQLiteReader.h and ABSQLiteReader.m into your project.
- Open "Build Phases" tab and under "Link Binary with Libraries" and add libsqlite3.dylib

### Import the project as a Cocoa Touch Framework (Objective-C and Swift)

- Drag ABSQLiteManager.xcodeproj in your project
- Open "Build Phases" under "Link Binary with Libraries" and add ABSQLiteManager.framework
- Import headers by using `@import ABSQLiteManager;` for Objective-C or `import ABSQLiteManager` for Swift


## License

ABSQLiteManager is available under the MIT license. See the LICENSE file for more info.
