function [ Info ] = getNeuronInfo( idString,settings,varargin )
if nargin==2
    printOutput = false;
else
    printOutput = true;
end
%% get neuron ID.
query = '{ neurons{ items{ id idString } } }';
[ response ] = dbFncs.callgraphql( settings.Database.SampleUrl, query);
id = [response.neurons.items];
id = id(find(cellfun(@(x) strcmp(x,idString), {id.idString}))).id;
%% get sample info.
query = sprintf('{ neuron(id:"%s"){ tag injection{ fluorophore{ name } brainArea{ name } sample { sampleDate } } } }',id);
[ response ] = dbFncs.callgraphql( settings.Database.SampleUrl, query);
sampleStr = datetime(response.neuron.injection.sample.sampleDate/1000,'ConvertFrom', 'posixtime');
sampleStr = datestr(sampleStr,'yyyy-mm-dd');
% Organize.
Info.sample    = sampleStr ;
Info.tag       = response.neuron.tag;
Info.fluorophore = response.neuron.injection.fluorophore.name;
Info.location  = response.neuron.injection.brainArea.name;

if printOutput
    fprintf('\nNeuron: %s',idString);
    fprintf('\n\t Sample: \t\t%s',Info.sample);
    fprintf('\n\t Tag: \t\t\t%s',Info.tag);
    fprintf('\n\t Fluorophore: \t%s',Info.fluorophore);
    fprintf('\n\t Location: \t\t%s',Info.location);
    fprintf('\n');
end

end

