function val=jsonopt(key,default,varargin)
    val=default;
    if(nargin<=2) return; end
        opt=varargin{1};
        if(isstruct(opt) && isfield(opt,key))
            val=getfield(opt,key);
    end
end