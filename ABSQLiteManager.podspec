
Pod::Spec.new do |s|
  s.name             = 'ABSQLiteManager'
  s.version          = '0.3'
  s.summary          = 'ABSQLiteManager is a lightweight SQLite reading library for iOS. It can be used to quickly convert SQLite database to Foundation objects.'
  s.description      = <<-DESC
                        It provides:

                            * Converting SQLite database to Foundation objects.
                            * Listing table structure
                            * Listing table names
                            * Listing column names
                            * Easily fetching rows from tables
                            * Easily fetching rows by using sql queries
                            * Support for NSPredicate
                            * Swift 4 support
                       DESC

  s.homepage         = 'https://github.com/kristapsz/ABSQLiteManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kristaps Zeibarts' => '' }
  s.source           = { :git => 'https://github.com/kristapsz/ABSQLiteManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'ABSQLiteManager/Classes/*.{h,m}'
  s.public_header_files = 'ABSQLiteManager/Classes/*.h'
  s.library = 'sqlite3'
end
