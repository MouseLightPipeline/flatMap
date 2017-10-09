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
pixPoints = round([swc(:,3:5),zeros(size(swc,1),1)]*tMat);
pixPoints = pixPoints(:,1:3);

indPix = sub2ind(size(lap),pixPoints(:,1),pixPoints(:,2),pixPoints(:,3));
indHit = find(~isnan(lap(indPix)) & swc(:,5)>5695);
swc = swc(indHit,:);
pixPoints = pixPoints(indHit,:);
%% Point to flatmap
% countStr = sprintf('0 of %i',size(pixPoints,1));
% fprintf('Unfolding Node: %s',countStr);
for iNode = 1:size(pixPoints,1)
    %Update message.
%     fprintf(repmat('\b',1,length(countStr)))
%     countStr = sprintf('%i of %i',iNode,size(pixPoints,1));
%     fprintf('%s',countStr);
tic
    [ xr, yr,zr ] = transformAllenPix2Flat( pixPoints(iNode,1), pixPoints(iNode,2), pixPoints(iNode,3),...
            Param.coeff1, Param.coeff2, Param.points3d, lap);
        toc
        
%          [ xr2, yr2,zr2 ] = transform3D_to_2D( pixPoints(iNode,1), pixPoints(iNode,2), pixPoints(iNode,3),...
%              Param.coeff1, Param.coeff2, Param.points3d, lap);
%          if ~isequal([xr,yr,zr],[xr2,yr2,zr2])
%             a=1
%          end
    swc(iNode,3:5) = [ xr, yr,zr ];
end
hold on
%  plotSwcFast2D(swc,[1,2]);
scatter(swc(:,3),swc(:,4))


figure;
scatter(Param.bdy(:,2), Param.bdy(:,1), 'b', 'LineWidth', 2)
hold on
%  plotSwcFast2D(swc,[1,2]);
scatter(swc(:,3),swc(:,4))
tic
    [ xr, yr,zr ] = transformAllenPix2Flat( 128,491,419,...
            Param.coeff1, Param.coeff2, Param.points3d, lap);
toc


figure
 plotSwcFast2D(swc,[1,2]);
 
 figure
 imshow(lap(:,:,pixPoints(iNode,3)),[])

 
 figure
 imshow(lap(:,:,600),[]);


