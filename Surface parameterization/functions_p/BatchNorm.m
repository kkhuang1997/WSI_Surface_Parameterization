function n = BatchNorm(vs,dim,p)

    if ~exist('dim','var') || isempty(dim), dim = 1;  end
    if ~exist('p','var') || isempty(p), p = 2;  end
    
    if ~isnumeric(p)
        error('Invalid norm.')
    end
    
    switch p
        case Inf,   n = max(abs(vs),[],dim);
        otherwise,  n = nthroot(sum(abs(vs).^p,dim),p); 
    end
end