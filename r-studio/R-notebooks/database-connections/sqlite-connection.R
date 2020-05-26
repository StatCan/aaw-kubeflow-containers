### This is an example of how to connect to a database.

### You'll want to create a new database, instead of using this
### database of latin expressions (Presumably), but you
### can copy-paste this example with a new database.

library(odbc)
library(DBI)
con <- dbConnect(
    odbc::odbc(), 
    .connection_string = paste(
        "Driver={SQLite3}",
        # Edit here
        "Database=latin_phrases.db",
        sep=";")
)
