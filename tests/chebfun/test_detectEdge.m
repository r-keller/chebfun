% Test file for @chebfun/detectEdge.m.

function pass = test_detectEdge(pref)

% We test detectEdge directly by giving it function handles with known
% discontinuities in the 0, ..., 4th derivatives.

% Initialise seed:
seedRNG(13);

% Number of points to test:
M = 10;
% Generate random points in [0, 1]:
x0 = rand(M,1);

% Initialise edge vector:
edge = zeros(M,1);

f = classicfun.constructor(0,struct('domain', [0 1]));

% Jump:
for j = 1:M
    edge(j) = detectEdge(f, @(x) exp(x)+cos(7*x)+0.1*sign(x-x0(j)), 1, 1);
end
err = norm(edge - x0, inf);
pass(1) = err < 5e-14;

% C1:
for j = 1:M
    edge(j) = detectEdge(f, @(x) exp(x)+cos(7*x)+0.1*abs(x-x0(j)), 1, 1);
end
err = norm(edge - x0, inf);
pass(2) = err < 5e-14;

% C2:
for j = 1:M
    edge(j) = detectEdge(f, @(x) sign(x-x0(j)).*(x-x0(j)), 1, 1);
end
err = norm(edge - x0, inf);
pass(3) = err < 5e-14;

% C3:
for j = 1:M
    edge(j) = detectEdge(f, @(x) abs(x-x0(j)).^3, 1, 1);
end
err = norm(edge - x0, inf);
pass(4) = err < 5e-14;

% C4:
for j = 1:M
    edge(j) = detectEdge(f, @(x) sign(x-x0(j)).*(x-x0(j)).^3, 1, 1);
end
err = norm(edge - x0, inf);
pass(5) = err < 5e-14;

end

