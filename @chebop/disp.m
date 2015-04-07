function disp(A)
%DISP   Display a CHEBOP by converting it to a pretty-printed string.
%
% See also DISPLAY.

% Copyright 2014 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

loose = strcmp(get(0, 'FormatSpacing'), 'loose');

if ( isempty(A) )
    fprintf('   (empty chebop)\n');
    if ( loose )
        fprintf('\n')
    end
    
else
    % Check whether the chebop is linear in order to be able to display
    % linearity information. 
    if ( isempty(A.op) )
        fprintf('   Empty operator');
    elseif ( islinear(A) )
        fprintf('   Linear operator');
    else
        fprintf('   Nonlinear operator');
    end
    if ( ~isempty(A.op) )
        fprintf(':\n')
        str = formatOperator(A.op);
        fprintf('      %s\n', str);
        if ( loose )
            fprintf('\n')
        end
        fprintf('  ');
    end
    fprintf(' operating on chebfun objects defined on:\n')
    dom = strtrim(sprintf('%g ', A.domain));
    fprintf('      [%s]\n', dom);
    if ( loose )
        fprintf('\n')
    end
    
    if ( ~isempty(A.lbc) || ~isempty(A.rbc) || ~isempty(A.bc) )
        fprintf('   with\n');
        if ( loose )
            fprintf('\n')
        end
    end
    
    if ( ~isempty(A.lbc) )
        fprintf('    left boundary conditions:\n');
        if ( ischar(A.lbc) )
            fprintf('      %s\n', A.lbc);
        elseif ( isnumeric(A.lbc) )
            fprintf('      %s\n', num2str(A.lbc));
        else
            str = stripHandle(func2str(A.lbc));
            fprintf('      %s = 0\n', str);
        end
        if ( loose )
            fprintf('\n')
        end
    end
    
    if ( ~isempty(A.rbc) )
        fprintf('    right boundary conditions:\n');
        if ( ischar(A.rbc) )
            fprintf('      %s\n', A.rbc);
        elseif ( isnumeric(A.rbc) )
            fprintf('      %s\n', num2str(A.rbc));
        else
            str = stripHandle(func2str(A.rbc));
            fprintf('      %s = 0\n', str);
        end
        if ( loose )
            fprintf('\n')
        end
    end
    
    if ( ~isempty(A.bc) )
        if ( strcmpi(A.bc, 'periodic') )
            fprintf('    periodic boundary conditions.\n');
        else
            fprintf('    constraints:\n');
            if ( ischar(A.lbc) )
                fprintf('      %s\n', A.bc);
            else
                str = stripHandle(func2str(A.bc));
                fprintf('      %s = 0\n', str);
            end
        end
        if ( loose )
            fprintf('\n')
        end
    end

end

end  % End of function DISP().

function str = stripHandle(op)
idx = strfind(op, ')');
str = op(idx(1)+1:end);

end

function str = formatOperator(op)
% What type of a function did we get passed?
opFunc = functions(op);

% Convert the function to a string:
op = func2str(op);

if ( strcmp(opFunc.type, 'simple') )
    % If the function passed was of the simple type, we simply return the
    % results of func2str above
    str = op;
    
else
    % We got passed an anonymous function. Return a string to print on a nice
    % form.
    idx = strfind(op, ')');
    args = op(3:idx(1)-1);
    % If we have any commas in args, the independent variable (e.g. x) must be
    % included. For nicer output, don't print it
    idxCommas = strfind(args, ',');
    if ( ~isempty(idxCommas) )
        args = args(idxCommas(1)+1:end);
    end
    
    % Isolate the actual operator part from the string
    op = op(idx(1)+1:end);
    
    % If we're dealing with a system, throw away the end [ and ]. Also, split up
    % components into lines.
    if ( op(1) == '[' && op(end) == ']' )
        op = op(2:end-1);
        
        % Replace ; with the ASCII character for new line. Add indentation to
        % make it look nice
        wSpace = repmat(' ', 1, length(args) + 11);
        op = strrep(op, ';', [char(13), wSpace]);
    end

    % Output string
    str = [args, ' |-> ', op];
end

end


function s = bc2char(b)

% Make sure b is a cell:
if ( ~iscell(b) )
    b = {b}; 
end

s = repmat({'     '},1,length(b));
for k = 1:length(b)
    if isnumeric(b{k})  % number
        s{k} = [s{k}, num2str(b{k})];
    elseif ischar(b{k})  % string
        s{k} = [s{k}, b{k}];
    else  % function
        s{k} = [s{k}, char(b{k}), ' = 0'];
    end
end

end

function s = mat2char(V)
% MAT2CHAR  Convert the varmat to pretty-print string (incl. BCs)

print_bc = true;       % Print BCs or not
defreal = 6;           % Size of matrix to display
dom = get(V,'domain');
numints = numel(dom.endsandbreaks);

if numints == 1 && isempty(V,'bcs')
    print_bc = false;
end

defreal = max(2,ceil(defreal/(numints-1)));
s1 = ['   with n = ',int2str(defreal),' realization:'];

% Evaluate the linop
if print_bc && ~isempty(V,'bcs')
    Vmat = feval(V,defreal,'bc',dom);
else
    Vmat = feval(V,defreal,'nobc',dom);
end

% Some pretty scaling for large/small numbers
M = max(max(abs(Vmat)));
if ( (M > 1e2 || M < 1) && M ~= 0 )
    M = 10^round(log10(M)-1);
    Vmat = Vmat/M;
    s1 = [s1 sprintf('\n    %2.1e * ',M)];
end

if isreal(Vmat)
    s2 = num2str(Vmat,'  %8.4f');
    for k = 1:size(s2,1)
        s2(k,:) = strrep(s2(k,:),' 0.0000','      0');
        if numel(s2(k,:)) > 5,
            s2(k,1:6) = strrep(s2(k,1:6),'0.0000','     0');
        end
        s2(k,:) = strrep(s2(k,:),'-0.0000','      0');
    end
else
    s2 = num2str(Vmat,'%8.2f');
    for k = 1:size(s2,1)
        s2(k,:) = strrep(s2(k,:),'0.00 ','   0 ');
    end
end

% Pad with appropriate spaces
s2 = [ repmat(' ',size(s2,1),5) s2 ];
s = char(s1,'',s2);
end
