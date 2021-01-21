function []=print2pdf(f,filename)
sli=find(filename=='\');            % Check if filename contains path 
if ~isempty(sli)                    % to a different folder:
    curdir=cd;                      % Store current directory
    figdir=filename(1:sli(end));    % Determine folder for figure
    filename(1:sli(end))=[];        % Exclude path from filename
    cd(figdir);                     % Change to figure folder
end 
%% Next, print as svg, and export to pdf with Inkscape
print(f,'-dsvg',filename);
inkscapepath = '"C:\Program Files\Inkscape\inkscape.exe"';
system( [inkscapepath ' ' filename ...
         '.svg --export-area-drawing --export-pdf=' filename '.pdf']);
delete([filename,'.svg']);          % Delete .svg file
if exist('curdir','var')
    cd(curdir);                     % Change back to original folder
end