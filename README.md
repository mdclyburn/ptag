# ptag
A simple way to tag files in a directory.

## Why ptag?
I wanted an easy way to tag a bunch of files sitting in a single directory. Other solutions were quite heavy, and I didn't need all of the functionality provided by them. Some of them simply wouldn't work on my systems.

## Installation
A single, small Perl script. Put it somewhere your PATH specifies; perhaps, rename it to simply 'ptag'.

## Usage
Ptag has a set of subcommands that make things work. The script looks for a file called `.ptagdb` in the current working directory. It reads this file for tags given to files in the directory. A single entry looks like this: `myfile.gif = funny,cat` (no spaces between tags). You can directly edit this file or let ptag work with it. Each entry goes on its own line.

### Commands
| Subcommand | Description |
|:-------------:|:-------------|
|newdb|create a new database and start adding tags|
|organize|sort the file list in .ptagdb|
|search|look for tags|
|update|look for new files to add to a pre-existing tag database|

#### Searching
You can search with `ptag search <tag list>`.
This is the only command that takes an argument.
If the database has the entry `myfile.gif = funny,cat`, then the following queries will return at least this file:

* `ptag search funny`
* `ptag search cat`
* `ptag search funny,cat`
* `ptag search funny,cat`

The following queries will not:

* `ptag search funy`
* `ptag search funny,cat,dog`

Anything and everything to do with the tag list is delimited with commas and never includes spaces.
