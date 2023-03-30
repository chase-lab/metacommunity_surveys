## Cache folder
This folder is used to locally save downloaded data before the processing step
In some cases, the downloaded data is a zip archive with GIS data, pictures and tables.
In the download script, the large archive is saved in the data/cache folder, unzipped and
only the tables are saved in a lightweight, compressed rdata.rds file in data/raw data.
