% Demonstration script for RPDR processing scripts

% Point this to the directory that contains the .txt files from RPDR
targetDirectory = 'C:\\Users\\mr118\\Desktop\\RPDR all panc cases\\';

RPDRData = CreateDatastoreFromRPDRTextFiles(targetDirectory);

% @@ TODO - demonstrate datastore access from this list
