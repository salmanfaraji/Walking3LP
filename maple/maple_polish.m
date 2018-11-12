
str = fileread('get_maple_DS.m');
str = strrep(str,'%Warning','Warning');
str = strrep(str,'Warning','%Warning');
fID = fopen('get_maple_DS.m','w');
fwrite(fID,str);
fclose(fID);

str = fileread('get_maple_SS.m');
str = strrep(str,'%Warning','Warning');
str = strrep(str,'Warning','%Warning');
fID = fopen('get_maple_SS.m','w');
fwrite(fID,str);
fclose(fID);

str = fileread('vis_maple_SS.m');
str = strrep(str,'%Warning','Warning');
str = strrep(str,'Warning','%Warning');
fID = fopen('vis_maple_SS.m','w');
fwrite(fID,str);
fclose(fID);

str = fileread('vis_maple_DS.m');
str = strrep(str,'%Warning','Warning');
str = strrep(str,'Warning','%Warning');
fID = fopen('vis_maple_DS.m','w');
fwrite(fID,str);
fclose(fID);

