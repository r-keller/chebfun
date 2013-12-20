function h = times(f,g)
%.*   Multiply DELTAFUNS with DELTAFUNS

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% Note: This method will be called only if both F and G are DELTAFUNS or at the
% most one of F and G is a scalar double.

%% Empty case:
h = deltafun;
if ( isempty(f) || isempty(g) )
    return
end

% Trivial cases:
% % Check if inputs are other than DELTAFUNS or doubles:
% if ( (~isa(f, 'deltafun') && ~isa(f, 'double')) || ...
%      (~isa(g, 'deltafun') && ~isa(g, 'double')) )
%     error( 'DELTAFUN:times', 'Input can only be a DELTAFUN or a double' )
% end

% Make sure F is a deltafun and copy the other input in g
if ( ~isa(f, 'deltafun') )
    % Then g must be a deltafun
    F = g;
    g = f;
else
    % f is a deltafun
    F = f;
end
    
%% Multiplication by a scalar
if ( isa(g, 'double') )
    h = F;
    % Scale everything and return:
    h.funPart = g * F.funPart;
    h.impulses = g * h.impulses;
    return
end

%% Multiplication by a FUN:
if ( isa(g, 'classicfun') )
    % Upgrade to a deltafun and recurse:
    s = deltafun.zeroDeltaFun(g.domain);
    s.funPart = g;
    h = F.*s;
    return
end

%% Multiplication of two DELTAFUNs:
if ( isa(g, 'deltafun') )
    h = deltafun;
    h.funPart = F.funPart .* g.funPart;

    if ( ~isempty(F.location) && ~isempty( g.location) )
       if ( ~isempty(deltafun.numIntersect(F.location, g.location)))
           error( 'CHEBFUN:DELTAFUN:times', 'delta functions at same points can not be multiplied' );
       end
    end
    
    impulses1 = [];
    impulses2 = [];
    if ( ~isempty(F.location) )
        impulses1 = funTimesDelta(g.funPart, F.impulses, F.location);
    end
    
    if ( ~isempty(g.location) )
        impulses2 = funTimesDelta(F.funPart, g.impulses, g.location);
    end
    
    [deltaMag, deltaLoc] = deltafun.mergeImpulses( impulses1, F.location, impulses2, g.location );
    h.impulses = deltaMag;
    h.location = deltaLoc;
    
else
    % Class of g unknown, throw an error:
    error( 'CHEBFUN:DELTAFUN:times', 'unknown argument type' );
end
%%
% Check if after multiplication h has become smooth:
if ( ~anyDelta(h) )
    h = h.funPart;
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What is the distribution f times a  sum of derivatives of delta functions
% all located at the point x?
% < f*delta^(n), phi > = sum < (-1)^(n-j) f^(n-j)delta^(j), phi>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = funTimesDelta(f, deltaMag, deltaLoc)

% Highest order delta function:
n = size(deltaMag, 1);
m = length(deltaLoc);

% Get all the derivatives needed and store them in a matrix:
Fd = zeros(n, m);
fk = f;
for k = 1:n
    Fd(k, :) = (-1)^(k-1)*feval(fk, deltaLoc);
    fk = diff(fk);
end
    
D = zeros(n, m);
for j = 1:m
    for i = 1:n 
        D(:, j) = D(:, j) + flipud(Fd(:, j)) * deltaMag(i, j);
    end
end
end
