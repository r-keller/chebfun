function F = imag(F)
%IMAG   Complex imaginary part of a CHEBFUN.
%   IMAG(F) is the imaginary part of F.
%
% See also REAL.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org for Chebfun information.

% Handle the empty case:
if ( isempty(F) )
    return
end

for j = 1:numel(F)

    % Take imaginary part of the impulses:
    % [TODO]:  Is this the right thing to do for higher-order impulses?
    F(j).impulses = imag(F(j).impulses);

    % Take imaginary part of the FUNs:
    for k = 1:numel(F(j).funs)
        F(j).funs{k} = imag(F(j).funs{k});
    end

end

end