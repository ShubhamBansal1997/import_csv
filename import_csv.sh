#!/bin/bash

# show commands being executed, per debug
set -x

#define database connectivtity
_db='csv_imports'
_db_user='root'
_db_password='Shubham98100'

# define directoty containting CSV file
_csv_directory="/Users/shubhambansal/Documents/import_csv/files"

# go into directory
cd $_csv_directory

# get a list of CSV files in directory
_csv_files=`ls -1 *.csv`

# loop through CSV files
full_flag=0
_table_name="csv_data_table"
mysql -u $_db_user -p$_db_password $_db << eof
    CREATE TABLE IF NOT EXISTS \`$_table_name\` (
      id int(11) NOT NULL auto_increment,
      PRIMARY KEY  (id)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1
eof
for _csv_file in ${_csv_files[@]}
do

  # remove file extendsion
  _csv_file_extensionless=`echo $_csv_file | sed 's/\(.*\)\..*/\1/'`


  # get header columns from CSV file
  _header_columns=`head -1 $_csv_directory/$_csv_file | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g'`
  _header_columns_string=`head -1 $_csv_directory/$_csv_file | sed 's/ /_/g' | sed 's/"//g'`
  _header_columns_string=${_header_columns_string%??};


  # loop through header columns
  if (( $full_flag % 2 == 0 ))
    then
    for _header in ${_header_columns[@]}
    do
    # add column

      mysql -u $_db_user -p$_db_password $_db --execute="alter table \`$_table_name\` add column \`$_header\` text"
      full_flag=1

    done
  fi
  mysqlimport --fields-enclosed-by='"' --fields-terminated-by=',' --lines-terminated-by="\n" --columns=$_header_columns_string -u $_db_user -p$_db_password $_db $_table_name < $_csv_directory/$_csv_file

done
exit

#
