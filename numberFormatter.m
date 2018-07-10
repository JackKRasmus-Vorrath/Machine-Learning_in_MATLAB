function y = NumberFormatter( Numbers , FormatPattern )
%NUMBERFORMATTER
%   NumberFormatter
%
%   The pound sign (#) denotes a digit, the comma is a placeholder for the
%   grouping separator, and the period is a placeholder for the decimal
%   separator.
%
%   The pattern specifies leading and trailing zeros, because the 0
%   character is used instead of the pound sign (#).
%
%   Examples:
%
%   NumberFormatter(rand(5),'0.000')
%     '0.315'    '0.601'    '0.700'    '0.085'    '0.359'
%     '0.244'    '0.973'    '0.462'    '0.173'    '0.667'
%     '0.023'    '0.632'    '0.161'    '0.936'    '0.164'
%     '0.380'    '0.013'    '0.599'    '0.784'    '0.124'
%     '0.305'    '0.225'    '0.256'    '0.131'    '0.577'
%
%   NumberFormatter(rand(5)*100,'###,###.000')
%     '8.599'     '26.809'    '44.056'    '55.940'    '21.168'
%     '97.392'    '74.909'    '23.245'    '23.203'    '43.105'
%     '43.989'    '53.318'    '1.212'     '24.249'    '6.736' 
%     '84.233'    '70.135'    '34.609'    '54.151'    '72.217'
%     '70.554'    '21.946'    '34.163'    '38.399'    '43.727'
%

import java.text.*

v = DecimalFormat(FormatPattern);
y = cell(size(Numbers));

for I =1:numel(Numbers)
    y{I} = char(v.format(Numbers(I)));
end
