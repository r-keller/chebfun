function F = csc(F, varargin)
%CSC   Cosecant of a CHEBFUN.
%   CSC(F) computes the cosecant of the CHEBFUN F.
%
%   CSC(F, PREF) does the same but uses the CHEBPREF object PREF when
%   computing the composition.
%
% See also ACSC, CSCD.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org for Chebfun information.

% Call the compose method:
F = compose(F, @csc, varargin{:});

end