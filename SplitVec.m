% Copyright (c) 2018, Bruno Luong
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
% list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution
% * Neither the name of FOGALE nanotech nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function varargout = SplitVec(v, fun, varargin)
% Purpose: Partition an input vector V into smaller series of subvectors
%          of consecutive elements based on split points
%
% EXAMPLE:
%       > s = SplitVec([1 1 1 2 2 3])
%       > s returned is: {[1 1 1] [2 2] [3]}
%
% INPUT:
%   V: main argument, array of the length n.
%      It can be also matrix, in this case SplitVec works along the first
%      dimension
%
%   FUN: Typical value 'equal' 'consecutive', 'reverse'
%       It can be a customized function that - when apply on V - returns 
%       a logical array of length n (or n-1), contains *true* at the same
%       location where the LAST element of a series (i.e., right before the
%       break occurs). Example:
%                   V: [5 5 5 2 2 3 3 3 4]
%              FUN(V): [0 0 1 0 1 0 0 1 1]
%       - By default FUN is 'equal': @(v) any(diff(v,1,dim),2)~=0
%         Group by series of equal elements. DIM is 2 for row vector
%         1 otherwise.
%       - Set FUN to 'consecutive': diff(V(:,1)-(1:n)')~=0 to split
%         into series of consecutive integers (n denotes size(V,1))
%       - Set FUN to 'reverse': diff(V(:,1)-(n:-1:1)')~=0 to split
%         in series of the reverse ordered integers
%   COL: Alternatively if the second parameter is an integer indexes,
%        the 'EQUAL' grouping will be carried out based only on the
%        specified column-indexes COL
%
%   TYPE<k> can take one of the string values:
%       - 'split': Split the vector V in cell. It is the DEFAULT output
%       - 'first' 'begining': index of the first element of a series,
%       - 'last' 'end': index of the last element of a series,
%       - 'firstval' 'firstelem': value of the first element,
%       - 'lastval' 'lastelem': value of the first element,
%       - 'length': the length of the series,
%       - 'bracket': the braket of the form [first last] of the series,
%       - 'loc' 'location' 'index', 'indice': the row indices (first:last)
%          of all series.
%       - 'block' 'blockid': Cell contains block ID of all series,
%         ID numerotations are {1,2,3,...}, each cell contains a row vector
%         of the same length P as the corresponding block, each vector has
%         constant ID repeated P times.
%       - 'subsetorder': a cell contains order within a series,
%         each cell contains a row vector (1:P) where P is
%         the of the length of the corresponding block.
%   User could provide a customized function handle for TYPE<k>.
%       The function takes as input a subarray of V (one splitted series)
%       and return a result.
%         Example: 
%           SplitVec([1 2 3 1 2],'cons',@(x) mean(x.^2))
%       - Additional input arguments are passed by the cell function
%         handle form
%         Example:
%           SplitVec([1 2 3 1 2],'cons',{@(x,p) mean(x.^p) 4})
%       - Use SplitVec(..., typefun, 'UniformOutput', false) to return
%         composite output result in cell array.
%
% OUTPUT:
%   See Type, by default V is splitted in series, stored in cell array.
%
% See also: sortrows, ismember, unique
%
% Author: Bruno Luong
% History:
%   17-May-2009 original
%   28-May-2009: multiple-column grouping
%   21-June-2009: correct bug when function handle is passed in second
%                 input.
%   07-Jul-2009: correct bug for empty array, group function
%                Add output types: 'firstval' 'lastval'
%   02-Feb-2010: correct bug when 'loc' is required when working
%                down the columns of matrix (NUMEL(V) -> SIZE(V,1)) 
%   26-Aug-2011: New builtin outputs: blockID and subsetorder
% 
% [out1, out2, ...] = SplitVec(V, FUN, type1, type2, ...)
% [out1, out2, ...] = SplitVec(V, COL, type1, type2, ...)
isrow = false;
% Reshape a row vector in column vector
if isvector(v) && size(v,1)==1
    isrow = true;
    v = v(:);
end

n = size(v,1);

groupfun = @(v) any(diff(v,1,1)~=0,2);
% Determine which function used for spliting
if nargin>=2 && ischar(fun)
    switch lower(fun)
        case {'group' 'same' 'eq' 'equal'}
            fun = groupfun;
        case {'cons' 'consecutive'}
            fun = @(v) diff(v(:,1)-(1:n)')~=0;
        case {'reverse'}
            fun = @(v) diff(v(:,1)-(n:-1:1)')~=0;
        otherwise
            fun = groupfun;
    end
elseif nargin>=2 && ...
       ~isa(fun,'function_handle') % case SplitVec(v, [1 3],...)
   if ~isempty(fun)
       col = fun;
       fun = @(v) any(diff(v(:,col),1,1)~=0,2);
   else
       fun = groupfun;
   end
elseif nargin<2 || isempty(fun)
    fun = groupfun;
end

% Check if additional arguments are provides (cell function handle)
if iscell(fun)
    arg = fun(2:end);
    fun = fun{1};
else
    arg = {};
end
b = feval(fun,v,arg{:});
if length(b)==size(v,1)-1
    b = [true; b(:); true];
elseif length(b)==size(v,1) % numel(b)==numel(v)
    b = [true; b(:)];
    b(end) = true;
else
    error('FUN returns incorrect output vector (wrong length)')
end
first = find(b);
lgt = diff(first);
first(end) = [];
if ~isempty(first)
    last = first + lgt -1;
else
    last = [];
end

% Assigned Output
if isempty(varargin)
    outtype = {'split'};
else
    outtype = varargin;
end
nout = length(outtype);
out =  cell(1,nout);

getsplit('clean');

for k=1:nout
    % Empty is set if function handles followed by 'UniformOutput'
    if isempty(outtype{k})
        continue
    end
    % Check if additional arguments are provides (cell function handle)
    if iscell(outtype{k})
        funk = outtype{k}{1};
        argk = outtype{k}(2:end);
    else % no
        funk = outtype{k};
        argk = {};
    end
    % Call user function handles 
    if isa(funk,'function_handle')
        split = getsplit(isrow, v, lgt);
        if k<=nout-2 && ischar(outtype{k+1}) && ...
           ~isempty(strmatch(outtype{k+1},'UniformOutput'))
            unif = outtype{k+2};
            outtype(k+1:k+2) = {[]};
        else
            unif = false;
        end
        out{k} = cellfun(@(obj) funk(obj, argk{:}), split, ...
                         'UniformOutput', unif);
    elseif ischar(funk)
        switch lower(funk)
            case {'split'}
                split = getsplit(isrow, v, lgt);
                out{k} = split;
            case {'first' 'begining'}
                out{k} = first;
            case {'last' 'end'}
                out{k} = last;
            case {'length'}
                out{k} = lgt;
            case {'firstval' 'firstelem'}
                out{k} = v(first,:);
                if isrow
                    out{k} = out{k}.';
                end               
            case {'lastval' 'lastelem'}
                out{k} = v(last,:);
                if isrow
                    out{k} = out{k}.';
                end
            case {'bracket'}
                out{k} = [first last];
            case {'loc' 'location' 'index', 'indice'}
                out{k} = mat2cell(1:size(v,1),1,lgt);
            case {'block' 'blockid'}
                % [ 1 1 1 2 2 3 ...] each block has a length in LGT 
                i = cumsum([0; lgt(1:end)])+1;
                block = zeros(1,i(end)-1);
                block(i(1:end-1)) = 1;
                block = cumsum(block);
                out{k} = mat2cell(block,1,lgt);
            case {'subsetorder'}
                % [ 1 1 1 2 2 3 ...] each block has a length in LGT 
                i = cumsum([0; lgt(1:end)])+1;
                suborder = ones(1,i(end)-1);
                suborder(i(2:end-1)) = 1-lgt(1:end-1);
                suborder = cumsum(suborder);
                out{k} = mat2cell(suborder,1,lgt);
            otherwise
                try % Try to evaluate as it is a function name
                    split = getsplit(isrow, v, lgt);
                    if k<=nout-2 && ischar(outtype{k+1}) && ...
                       ~isempty(strmatch(outtype{k+1},'UniformOutput'))
                        unif = outtype{k+2};
                        outtype(k+1:k+2) = {[]};
                    else
                        unif = false;
                    end
                    out{k} = cellfun(@(obj) feval(funk, obj, argk{:}), ...
                                     split, 'UniformOutput', unif);
                catch %#ok
                    error('unknown outtype %s', out{k})
                end
        end % switch
    end % ischar
end % for-loop on outputs

varargout=out;

getsplit('clean');

end % SplitVec

% Get a split arrays, do it once only, nested function
function s = getsplit(isrow, v, lgt)
persistent SPLIT
if ischar(isrow) && strcmpi(isrow,'clean')
    SPLIT = [];
elseif ~iscell(SPLIT)
    if ~isrow
        SPLIT = mat2cell(v,lgt,size(v,2));
    else
        SPLIT = mat2cell(reshape(v,1,[]),1,lgt);
    end
    s = SPLIT;
else
    s = SPLIT;
end

end % getsplit
