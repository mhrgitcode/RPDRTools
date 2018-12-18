%% Create datastore objects for a set of RPDR export files
% TO DO
% - Complete format definitions for all suffixes
% 
% All files RPDR text files within targetDirectory will be added to the
% datastore
function dataOutput = CreateDatastoreFromRPDRTextFiles(targetDirectory)

RPDRFieldDelimiter = '|'; % Character used by RPDR to separate fields in these text files
RPDRFileExtension = 'txt';  % File extension


% ---------------------------------------------------------------
% Define standard input formats for RPDR files
% ---------------------------------------------------------------

% Define possible RPDR input data types and associated column formats
RPDRSuffixList = {'Con'; 'Dem'; 'Dia'; 'End'; 'Lab'; 'Mrn'; 'Opn'; 'Pat'; 'Phy'; 'Prc'; 'Rad'; 'Rdt'; 'Rfv'};
numRPDRFileTypes = size(RPDRSuffixList,1);

% Define descriptions for each item in the suffix list
RPDRDescriptionList = {'Contact Information'; 'Demographics'; 'Diagnoses'; 'Endoscopy Reports'; ...
    'Lab Results'; 'Medical Record Numbers'; 'Operative Reports'; 'Pathology Reports'; ...
    'Physical and Vital Status Data'; 'Procedures'; 'Radiology Reports'; 'Radiology Exam Data'; 'Reason for Visit'};
   
% Assemble a table to hold the description and format data for each data
% type
RPDRInputTable = table('Size',[numRPDRFileTypes 3], 'VariableTypes', {'cell' 'string' 'cell'},...
    'VariableNames',{'FileSuffix' 'InputFormat' 'Description'}, 'RowNames', RPDRSuffixList);

RPDRInputTable.FileSuffix = RPDRSuffixList;
RPDRInputTable.Description = RPDRDescriptionList;

% Define standard formats for each RPDR file type
% Standards:
% EMPI - store as float. Should not contain any text.
% EPIC_PMRN - same
% MRN_Type - text
% MRN - text due to leading zeros

% Code to get draft input format: 
% filepath = [targetDirectory '*Pat' '.' RPDRFileExtension];
% testds = tabularTextDatastore(filepath, ...
%       'ReadVariableNames', true, ...
%       'Delimiter', RPDRFieldDelimiter)
% draftFormat = [testds.TextscanFormats{:}]
% testds.VariableNames

RPDRInputTable({'Con'},{'InputFormat'}) = {"%f%f%q%q%q%q%q%q%q%q%q%q%f%q%f%f%f%q%q%q%q%q%q%q%q"};
RPDRInputTable({'Dem'},{'InputFormat'}) = {"%f%f%q%q%q%{MM/dd/uuuu}D%f%q%q%q%q%q%f%q%q%q"};
RPDRInputTable({'Dia'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu}D%q%q%q%q%q%q%q%q%q"};
RPDRInputTable({'End'},{'InputFormat'}) = {"%f%f%q%q%f%{MM/dd/uuuu hh:mm:ss aa}D%q%q%q%q"};
RPDRInputTable({'Lab'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu HH:mm}D%q%q%q%q%f%q%q%q%q%f%q%f%q%f%q%q%q"};
RPDRInputTable({'Mrn'},{'InputFormat'}) = {"%f%q%q%f%f%f%f%f%f%f%f%f"};
RPDRInputTable({'Opn'},{'InputFormat'}) = {"%f%f%q%q%f%{MM/dd/uuuu hh:mm:ss aa}D%q%q%q%q"};
RPDRInputTable({'Pat'},{'InputFormat'}) = {"%f %f %q %q %s %{MM/dd/uuuu hh:mm:ss aa}D %q %s %s %q"};
RPDRInputTable({'Phy'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu}D%q%q%f%f%q%q%q%q%q%q"};
RPDRInputTable({'Prc'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu}D%q%q%f%f%f%q%q%q%q%q"};
RPDRInputTable({'Rad'},{'InputFormat'}) = {"%f%f%q%q%q%{MM/dd/uuuu hh:mm:ss aa}D%q%q%q%q"};
RPDRInputTable({'Rdt'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu}D%q%q%q%q%q%q%q%q%q"};
RPDRInputTable({'Rfv'},{'InputFormat'}) = {"%f%f%q%q%{MM/dd/uuuu hh:mm:ss aa}D%{MM/dd/uuuu hh:mm:ss aa}D%q%q%q%q%q%q%q"};

  

  %% DATASTORE CREATION
  % Create a datastore for every type of RPDR file in the target directory
  tempOutputStruct = struct([]);
  numOutputRows = 0;
  
  for suffixNum = 1:height(RPDRInputTable),
      filepath = [targetDirectory '*' cell2mat(RPDRInputTable{suffixNum,{'FileSuffix'}}) '.' RPDRFileExtension];
      fileList = dir(filepath);
      if ~isempty(fileList),   % Add entry to output array
          numOutputRows = numOutputRows + 1;
          tempOutputStruct(numOutputRows).tableIndex = suffixNum; % Index to main RPDR table
          
          % Create a tabular data store, which is a mechanism that allows
          % access of large multifile data sets. Does not read data at
          % creation.
          tempOutputStruct(numOutputRows).datastore = tabularTextDatastore({fileList(:).name}, ...
              'ReadVariableNames', true, ...
              'Delimiter', RPDRFieldDelimiter, ...
              'TextscanFormats', RPDRInputTable{suffixNum,{'InputFormat'}});
          
          % Also create a tall table to access the datastore content. Tall
          % tables allow for table-like processing across multiple files
          % and for data that would exceed local memory
          %tempOutputStruct(numOutputRows).tt = tall(tempOutputStruct(numOutputRows).datastore);
      end
  end
  
  % Debugging
  %temp = readtable('MR118_20181116_115024_End', 'Format',RPDRInputTable{{'End'},{'InputFormat'}}, 'Delimiter',RPDRFieldDelimiter, 'ReadVariableNames', true, 'Range','1:10');
  
  
  %% Prepare output table
  % Output table with one row per RPDR table type including description and
  % datastore link
  
  dataOutput = table(RPDRInputTable{[tempOutputStruct.tableIndex],{'FileSuffix'}},...
      RPDRInputTable{[tempOutputStruct.tableIndex], {'Description'}},...
      {tempOutputStruct(:).datastore}', ...
      tempOutputStruct(:).tt');

  
  