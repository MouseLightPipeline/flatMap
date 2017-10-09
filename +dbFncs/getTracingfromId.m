function [ data ] = getTracingfromId( id,url)
%getTracingfromId

%% Call database.
query = sprintf('{ tracings(queryInput: {swcTracingIds: "%s"}) { tracings { nodes { sampleNumber x y z parentNumber structureIdValue brainArea { structureId atlasId safeName acronym structureIdPath } } } } }',...
    id);
[ data ] = dbFncs.callgraphql( url, query);
%% Sort according to node ID.
data = data.tracings.tracings.nodes;
[~,ind] = sort([data.sampleNumber]','ascend');
data = data(ind);
%% Clean up output to single structure.
fn2 = fieldnames(data(1).brainArea);
%% check for empty anatomy fields.
emptyInd = find(cellfun(@(x) isempty(x), {data.brainArea}));
for i=emptyInd
data(i).brainArea = struct('structureId',[],'atlasId',[],'safeName',[],'acronym',[],'structureIdPath',[]); 
end
ana = squeeze(struct2cell([data.brainArea]));
data = rmfield(data,'brainArea');
fn1 = fieldnames(data(1));
fn = [fn1',fn2'];
data = struct2cell(data);
data = [data',ana'];
data = cell2struct(data',fn);

end

