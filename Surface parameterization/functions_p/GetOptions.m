function varargout = GetOptions(options,FieldName,defaultopts)

if nargin == 1
    FieldName = fieldnames(options);
    defaultopts = options;
end

if ischar(FieldName)
    if ~isfield(options,FieldName)      
        varargout = {defaultopts.(FieldName)};         
    else
        varargout = {options.(FieldName)};  
    end
else
    NumField = length(FieldName);
    varargout = cell(NumField,1);
    for i = 1:NumField
        Name = FieldName{i};
        if ~isfield(options,Name)      
            varargout{i} = defaultopts.(Name);         
        else
            varargout{i} = options.(Name);  
        end
    end
end

end