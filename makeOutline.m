bank = [];
downSample =10;
for iFrame = 1:size(lap,3)
    iFrame
    I = imresize(lap(:,:,iFrame),1/downSample);
    [i,j]= find(~isnan(I));
    i=i*downSample;
    j=j*downSample;
    if ~isempty(i)
        new = zeros(size(i,1),3);
        for iNode = 1:size(i,1)
            [ xr, yr,zr ] = transformAllenPix2Flat( i(iNode),j(iNode), iFrame,...
                    Param.coeff1, Param.coeff2, Param.points3d, lap);
            new(iNode,:) = [ xr, yr,zr ];
        end
        bank = [bank;new];
    end
end

% figure
% imshow(I,[]);

figure
scatter(bank(:,1),bank(:,2));
hold on
scatter(Param.bdy(:,1), Param.bdy(:,2), 'b', 'LineWidth', 2)

save('bank.mat','bank');
