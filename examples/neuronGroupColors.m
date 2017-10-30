%% Parameters.
Cells = {'AA0265','AA0267','AA0269'};
Color = {[1,0,0],[0,1,0],[1,0,1]};



% Cells = {'AA0034','AA0064'};
% Color = {[1,0,0],[0,1,0]};
%% Load Map.
load('anatomyFlatMap.mat');

%% Recalculate resIm to unique colors
[uniVal,b,c] = unique(resIm);
resImUni = resIm;
resImUni(:) = c;
resImUni = reshape(resImUni,size(resIm));
cMapUni = parula(length(uniVal));
cMapUni(1,:) = [0,0,0];

%% Plot.
hFig = figure;
hAx = axes;
hAx.DataAspectRatio = [1,1,1];
% imshow(resIm,R,[1,730],'ColorMap',cMap)
imshow(resImUni,R,[],'ColorMap',cMapUni)
hAx.YDir = 'normal';
hold on
for iCell=1:size(Cells,2)
    [outputData]=mapNeuron(Cells{iCell},'Type','axon','Output',false);
    scatter(outputData(:,1),outputData(:,2),10,Color{iCell},'filled');
end

