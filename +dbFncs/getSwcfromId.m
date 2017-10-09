function [ data ] = getSwcfromId( id,url)
%getTracingfromId
%% Call database.
query = sprintf('{ tracingNodes(id: "%s") { sampleNumber structureIdValue x y z parentNumber } tracing(id: "%s") { offsetX offsetY offsetZ } }',...
    id,id);
[ data ] = dbFncs.callgraphql( url, query);
offset = data.tracing;
data = data.tracingNodes;

%% Add offset.
% This is ugly and I dont care.
for i =1:size(data,1)
    data(i).x = data(i).x + offset.offsetX;
    data(i).y = data(i).y + offset.offsetY;
    data(i).z = data(i).z + offset.offsetZ;
end
end
