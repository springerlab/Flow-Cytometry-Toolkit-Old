function outstr = underscorify(str,leadingnum)
% UNDERSCORIFY cleans up a string for use as a variable name
%
%   UNDERSCORIFY(STR) replaces all non-alphanumeric characters in a string with
%   underscores. 
%   
%   UNDERSCORIFY(STR,LEADINGNUM) If LEADINGNUM is true and the string
%   starts with a number, the letter 'x' is appended to the beginning of
%   the string.
%
%   2012/07/12
outstr = str;
outstr(~isstrprop(str,'alphanum')) = '_';
if exist('leadingnum')==1
    if isstrprop(outstr(1),'digit')
        outstr = ['x' outstr];
    end
end