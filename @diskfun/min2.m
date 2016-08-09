function varargout = min2(varargin)
%MIN2   Global minimum of a DISKFUN.
%   M = MIN2(F) returns the global minimum of F over its domain. 
%   
%   [M, LOC] = MIN2(F) returns the global minimum in M and its location in
%   LOC.
%
%  This command may be faster if the OPTIMIZATION TOOLBOX is installed.
%
% See also DISKFUN/MAX2, DISKFUN/MINANDMAX2.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% we want to search over polar coords for the max: 
%iscart = diskfun.coordsetting(varargin{:}); 
f = varargin{1}; 

if ( isempty(f) )
 varargout= []; 
 return
end

%give cdr to separableApprox
[c, d, r] = cdr(f); 
f = c*d*r.'; 
[out{1:nargout}] = min2@separableApprox(f);
if numel(out) == 1
    varargout = out;
else
  %return loc var as Cartesian coords
        [val, loc] = out{:};
        t = loc(1); 
        loc(1) = loc(2).*cos(t); 
        loc(2) = loc(2).*sin(t); 
        varargout = {val, loc};
end

end
