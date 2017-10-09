function [ neuron ] = getNeuronfromIdString( idString,Settings )
% Parameters.
halfPoint = 5695;
%getNeuronfromIdString
query = '{ swcTracings{ id tracingStructure{ name } neuron{ idString } } }';
[ response ] = dbFncs.callgraphql( Settings.Database.TracingsUrl , query);
id = [response.swcTracings(:).neuron];
ind = find(cellfun(@(x) strcmp(x,idString), {id.idString}));
selected = response.swcTracings(ind);
% Find axon/dendrite.
structNames = [selected.tracingStructure];
if ~isempty(structNames)
    structNames = {structNames.name};
    axonInd = find(strcmp(structNames,'axon'));
    dendInd = find(strcmp(structNames,'dendrite'));
    % Store axon info.
    if isempty(axonInd)
        warning('Found no axon tracing for: %s',idString);
        neuron.axon = [];
    else
        if length(axonInd)>1
            warning('Found multiple axon tracings for %s',idString);
        end
        neuron.axon        = dbFncs.getTracingfromId( selected(axonInd(1)).id,Settings.Database.TracingsUrl );
        % Force hemisphere.
        if (strcmp(Settings.ForceHemisphere,'Left') && neuron.axon(1).x<halfPoint)...
                || ( strcmp(Settings.ForceHemisphere,'Right') && neuron.axon(1).x>halfPoint)
            tMat = eye(4,4);
            tMat(1,1) = -1;
            for i = 1:size(neuron.axon,1)
                newCoord = tMat*[neuron.axon(i).x,neuron.axon(i).y,neuron.axon(i).z,0]';
                neuron.axon(i).x = newCoord(1)+halfPoint*2;
                neuron.axon(i).y = newCoord(2);
                neuron.axon(i).z = newCoord(3);
            end
        end
    end
    % Store dendrite.
    if isempty(dendInd)
        warning('Found no dendrite tracing for: %s',idString);
        neuron.dendrite = [];
    else
        if length(dendInd)>1
            warning('Found multiple axon tracings for %s',idString);
        end
        neuron.dendrite        = dbFncs.getTracingfromId( selected(dendInd(1)).id,Settings.Database.TracingsUrl );
         % Force hemisphere.
        if (strcmp(Settings.ForceHemisphere,'Left') && neuron.dendrite(1).x<halfPoint)...
                || ( strcmp(Settings.ForceHemisphere,'Right') && neuron.dendrite(1).x>halfPoint)
            tMat = eye(4,4);
            tMat(1,1) = -1;
            for i = 1:size(neuron.dendrite,1)
                newCoord = tMat*[neuron.dendrite(i).x,neuron.dendrite(i).y,neuron.dendrite(i).z,0]';
                neuron.dendrite(i).x = newCoord(1)+halfPoint*2;
                neuron.dendrite(i).y = newCoord(2);
                neuron.dendrite(i).z = newCoord(3);
            end
        end
    end
else
    warning('Could not find reconstruction in database for neuron: %s',idString);
    neuron.axon = [];
    neuron.dendrite = [];
end
end

