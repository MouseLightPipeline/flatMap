%% parameters.
allenMeshFile = 'Z:\Allen_compartments\Matlab\allenMeshCorrectedAxis.mat';
anatomyList = {'Anterior cingulate area','Agranular insular area','Auditory areas','Ectorhinal area','Frontal pole, cerebral cortex',...
    'Gustatory areas','Infralimbic area','Primary Motor area','Secondary Motor area','Orbital area','Perirhinal area','Prelimbic area',...
    'Posterior parietal association areas','Retrosplenial area','Primary somatosensory area','Supplemental somatosensory area',...
    'Temporal association areas','Visceral area','Visual Areas'};
% anatomyList = {'Isocortex'};
pixSpacing = [50,50,50];
sliceRange = [-5000,5000];
resBin = [0.015,0.015];
imageRange = [-1.5,1.5;0,1.6];
%% Load mesh info.
fprintf('\nLoading allen Mesh info');
load(allenMeshFile);

%% Get anatomy locations.
meshList = [];
for iAna = 1:size(anatomyList,2)
    ind = find(strcmpi({allenMesh.name},anatomyList{iAna}));
    if ~isempty(ind)
        meshList = [meshList,ind];
    else
        error('\nCould not find %s',anatomyList{iAna});
    end
end

%% Map meshes.
gridX = pixSpacing(1)/2:pixSpacing(1):(1140*10);
gridY = pixSpacing(2)/2:pixSpacing(2):(800*10);
gridZ = pixSpacing(3)/2:pixSpacing(3):(1320*10);
ontIm = zeros(size(gridX,2),size(gridY,2),size(gridZ,2),'double');

%% Go through list.
for iStruct = 1:length(meshList)
    fprintf('\n[%s] Structure %i of %i',datestr(now,'HH:MM'),iStruct,length(meshList));
    cStruct = meshList(iStruct);
    %rename fields for function.
    meshFV = struct('faces',allenMesh(cStruct).f,'vertices',allenMesh(cStruct).v);
    BW = VOXELISE(gridX,gridY,gridZ,meshFV) ;
    ontIm(BW) =  cStruct;
end
% permute to match lap.
ontIm = permute(ontIm,[2,3,1]);
tMat = eye(3,3);
tMat(1,1) = pixSpacing(2);
tMat(2,2) = pixSpacing(3);
tMat(3,3) = pixSpacing(1);

%% make color map.
cMap = [0,0,0];
for iAna = 1:size(allenMesh,1)
    cMap = [cMap;hex2rgb(allenMesh(iAna).color)];
end


%% only run Right hemisphere.
halfPoint = round([1,1,5695]*inv(tMat));

%% Loading Laplacian info.
fprintf('\nLoading Laplacian Info');
[cFolder,~,~] = fileparts(which('makeOutline'));
load(fullfile(cFolder,'precalculated','lap10.mat')); % load lap and metalap
lap(lap==0)=NaN('single');
Param = load(fullfile(cFolder,'precalculated','calc_param.mat')); % load lap and metalap

%% Go through ontology map.
mappedOnt = [];
for iFrame = 1:halfPoint(3)+1
   fprintf('\nProcessing frame %i of %i',iFrame,halfPoint(3)+1);
   [i,j,k] = find(ontIm(:,:,iFrame)>0);
   voxCoords = [i,j,repmat(iFrame,size(i,1),1)]*tMat;
   for iVox = 1:size(voxCoords,1)
       if ~isnan(lap( voxCoords(iVox,1)/10,voxCoords(iVox,2)/10, voxCoords(iVox,3)/10))
            [ xr, yr,zr ] = transformAllenPix2Flat( voxCoords(iVox,1)/10,voxCoords(iVox,2)/10, voxCoords(iVox,3)/10,...
                    Param.coeff1, Param.coeff2, Param.points3d, lap);        
                mappedOnt = [mappedOnt;xr,yr,zr,ontIm(i(iVox),j(iVox),iFrame)+1];
       end
   end
end
% mirror for other hemisphere.
mappedOnt = [mappedOnt;[-mappedOnt(:,1),mappedOnt(:,2:4)]];

%% Make map image
resIm = zeros(ceil((imageRange(2,2)-imageRange(2,1))/resBin(2)),ceil((imageRange(1,2)-imageRange(1,1))/resBin(1)));
R = imref2d(size(resIm),imageRange(1,:),imageRange(2,:));
% select slice
indSlice = find(mappedOnt(:,3)>=sliceRange(1) & mappedOnt(:,3)<=sliceRange(2));
[I,J] = R.worldToSubscript(mappedOnt(indSlice,1),mappedOnt(indSlice,2));
indPix = sub2ind(size(resIm),I,J);
% fil in values (mode selection)
% resIm(indPix) = mappedOnt(indSlice,4);
[uniPix,~,listOrder] = unique([I,J],'rows');
for iPix = 1:size(uniPix,1)
    ind = listOrder ==iPix;
    resIm(uniPix(iPix,1),uniPix(iPix,2)) = mode(mappedOnt(ind,4));
end
% 
% save('map.mat','resIm','R','cMap');

%% Plot result.
hFig = figure;
hAx = axes;
imshow(resIm,R,[1,730],'ColorMap',cMap);hold on;
hAx.YDir = 'normal';
hAx.DataAspectRatio = [1,1,1];

%%
resIm = imfill(resIm);
save('map.mat','resIm','R','cMap');


hFig = figure;
hAx = axes;
imshow(resIm,R,[1,730],'ColorMap',cMap);hold on;
hAx.YDir = 'normal';
hAx.DataAspectRatio = [1,1,1];


hFig = figure;
hAx = axes;
imshow(resIm,R,[1,730],'ColorMap',jet(730));hold on;
hAx.YDir = 'normal';

