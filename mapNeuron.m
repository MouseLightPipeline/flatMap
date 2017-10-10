%% Input Parameters
neuronId = 'AA0100';
type = 'axon';

%% Parameters.
Settings.VoxelSize = [10,10,10];
Settings.ForceHemisphere = 'Right';
Settings.Database.TracingsUrl = 'http://ml-ubuntu-test:9661/graphql';

%% Load neuron from database.
fprintf('\nLoading neuron: %s',neuronId);
neuron = dbFncs.getNeuronfromIdString(neuronId,Settings);

%% Load pre-generated flat map.
fprintf('\nLoading Laplacian Info');
[cFolder,~,~] = fileparts(which('mapNeuron'));
load(fullfile(cFolder,'precalculated','lap10.mat')); % load lap and metalap
lap(lap==0)=NaN('single');
Param = load(fullfile(cFolder,'precalculated','calc_param.mat')); % load lap and metalap

%% Points to Pix. (LAPLACIAN DIM ORDER Y,Z,X)
% transform matrix.
tMat = eye(4,4);
for iDim=1:3
    tMat(iDim,iDim) = 1/Settings.VoxelSize(iDim);
end
swc = [[neuron.(type).sampleNumber]' [neuron.(type).structureIdValue]' [neuron.(type).y]' [neuron.(type).z]' [neuron.(type).x]' ones(size(neuron.axon,1),1) [neuron.(type).parentNumber]'];
% get indices in laplacian matrix.
pixPoints = round([swc(:,3:5),zeros(size(swc,1),1)]*tMat);
pixPoints = pixPoints(:,1:3);
indPix = sub2ind(size(lap),pixPoints(:,1),pixPoints(:,2),pixPoints(:,3));
% Filter for nodes on cortex.
indHit = find(~isnan(lap(indPix)));
swc = swc(indHit,:);
indPix = indPix(indHit,:);
pixPoints = pixPoints(indHit,:);

%% Process per hemisphere for symmetry.
swcHemi = [];
swcHemi.left = [];
swcHemi.right = [];
for iHemi = {'left','right'}
    % Select nodes on hemisphere.
    switch iHemi{:}
        case 'left'
            nodeList = find(swc(:,5)>5695);
        case 'right'
            nodeList = find(swc(:,5)<=5695);
    end
    %% Point to flatmap
    fprintf('\nTransforming points for %s hemisphere',iHemi{:});
    for iNode = 1:size(nodeList,1)
        cNode = nodeList(iNode);
        switch iHemi{:}
            case 'left'
                [ xr, yr,zr ] = transformAllenPix2Flat( pixPoints(cNode,1), pixPoints(cNode,2), size(lap,3)-pixPoints(cNode,3),... % you do mimus the total X lenngth because the direction of the dimenions is reversed (low is left hemisphere and high is right hemisphere)
                        Param.coeff1, Param.coeff2, Param.points3d, lap);
            case 'right'
                [ xr, yr,zr ] = transformAllenPix2Flat( pixPoints(cNode,1), pixPoints(cNode,2), pixPoints(cNode,3),...
                        Param.coeff1, Param.coeff2, Param.points3d, lap);             
                xr = (-xr );
            end
        swcHemi.(iHemi{:}) = [ swcHemi.(iHemi{:}) ; swc(cNode,1:2) xr, yr,zr, swc(cNode,6:7) ];
    end
    %% reformat swc info.
    swcHemi.(iHemi{:})(:,8) = swcHemi.(iHemi{:})(:,1); %store original node Id.
    swcHemi.(iHemi{:})(:,1) = [1:size(swcHemi.(iHemi{:}),1)]';
    for iNode = 1:size(swcHemi.(iHemi{:}),1)
       ind = find(swcHemi.(iHemi{:})(:,8) == swcHemi.(iHemi{:})(iNode,7));
       if ~isempty(ind)
        swcHemi.(iHemi{:})(iNode,7) = swcHemi.(iHemi{:})(ind,1);
       else
           swcHemi.(iHemi{:})(iNode,7) =-1;
       end
    end
end

hFig = figure;
hAx = axes;
hAx.DataAspectRatio = [1,1,1];
imshow(resIm,R,[1,730],'ColorMap',cMap);hold on;
hAx.YDir = 'normal';
scatter(swcHemi.left(:,3),swcHemi.left(:,4),10,'white','filled');
hold on
scatter(swcHemi.right(:,3),swcHemi.right(:,4),10,'white','filled');
export_fig(hFig,'Z:\Chip_analysis\AA0100 flatmap.png','m4')

hFig = figure;
hAx = axes;
hAx.DataAspectRatio = [1,1,1];
scatter(swc(:,5),swc(:,3),3,'filled');
hAx.YDir ='reverse';

hFig = figure;
hAx = axes;
hAx.DataAspectRatio = [1,1,1];
plotSwcFast2D(swcHemi.left,[1,2]); hold on
plotSwcFast2D(swcHemi.right,[1,2]); hold on

figure
imshow(lap(:,:,100),[]);

