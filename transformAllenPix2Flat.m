function [ xr, yr,zr ] = transformAllenPix2Flat( a0, b0, c0, coeff1, coeff2, randomPoints, laplacian)
%TRANSFORM3D_TO_2D Summary of this function goes here
%   input:
%   xi,yi,zi: are the input 3D values
%   coeff1, coeff2, randomPoints: are the data used to perform the
%       transform from previous analysis
%   laplacian: this is an image of the allen brain as a laplacian function
%       used to project the 3D points to the surface 
%   
%   Output:
%       xr, yr: the x and y coordinates in the flat map space

xi = randomPoints(:,1);
yi = randomPoints(:,2);
zi = randomPoints(:,3);
[a, b, c, d] = allenToSuraceTransform( a0, b0, c0, laplacian);
sum1 = 0;
sum2 = 0;
for j = 1:1427
    temp = sqrt((a-xi(j))^2 + ...
                (b-yi(j))^2 + ...
                (c-zi(j))^2);
    temp1 = coeff1(j)*temp;
    sum1 = sum1 + temp1;
    temp2 = coeff2(j)*temp;
    sum2 = sum2 + temp2;
end
a_const1 = coeff1(1428) + coeff1(1429)*a + ...
           coeff1(1430)*b + coeff1(1431)*c;
a_const2 = coeff2(1428) + coeff2(1429)*a + ...
           coeff2(1430)*b + coeff2(1431)*c; 
% xr = ((a_const1+sum1)+1)*500;
% yr = ((a_const2+sum2)+1)*500;
xr = (a_const1+sum1);
yr = (a_const2+sum2);
zr = d;
end

function [a, b, c, startZ] = allenToSuraceTransform(xi, yi, zi, laplacian)
%% allenToSuraceTransform
%   This function projects the 3D point in allen space to the surface of
%   the brain.
%   This function works very similar to how we find max projections but we
%   move through the laplacian in reverse
% oX = xi;
% oY = yi;
% Oz = zi;
startZ = laplacian(xi,yi,zi);
currentLayerValue = startZ;
maxIterations = 500;
it = 0; % to mae sure we dont end up in an infinite loop
sRad= 1;
while currentLayerValue < 5000 && it < maxIterations
       %% get max value nearby pixels.
       subList = repmat([xi,yi,zi],6,1)+ [1,0,0;-1,0,0;0,1,0;0,-1,0;0,0,1;0,0,-1];      
       subInd = sub2ind(size(laplacian),subList(:,1),subList(:,2),subList(:,3));
       
      [newVal,ii] = max(laplacian(subInd),[],'omitNan');
      % check if new value is higher.
      if newVal>currentLayerValue
          % update xyz.
          xi = subList(ii,1);
          yi = subList(ii,2);
          zi = subList(ii,3);
          currentLayerValue = newVal;
      else
          break
      end
      it = it + 1;
%     updated = false;
%     
%     NB = neighborhoodIndexes(xi, yi, zi, imgSize, stepSize);
%     
%     for i = 1:size(NB,1)
%         a1 = NB(i,1); b1 = NB(i,2); c1 = NB(i,3);
%         tempLap = laplacian(a1,b1,c1);
%         
%         if tempLap > currentLayerValue && tempLap ~= 0
%             currentLayerValue = tempLap;
%             xi = a1; yi = b1; zi = c1;
%             updated = true;
%         end    
%     end
%     % break if nothing is changing. (Johan)
%     if updated==false
%         break
%     end
%     it = it + 1;
end

a = xi; b = yi; c = zi;

end

function [NB] = neighborhoodIndexes(a,b,c,img, step)
%   Returns a vector of all of the pixel indexes in the neighborhood and
%   checks the bounds of the image.

i = 1;
s= size(img);
if a + step < s(1)
    NB(i,1) = a+step; NB(i,2) = b; NB(i,3) = c;
    i = i + 1;
end

if a-step > 0
    NB(i,1) = a-step; NB(i,2) = b; NB(i,3) = c;
    i = i + 1;
end

if b+step < s(2)
    NB(i,1) = a; NB(i,2) = b+step; NB(i,3) = c;
    i = i + 1;
end

if b-step > 0
    NB(i,1) = a; NB(i,2) = b-step; NB(i,3) = c;
    i = i + 1;
end

if c+step < (s(3) + 1)
    NB(i,1) = a; NB(i,2) = b; NB(i,3) = c+step;
    i = i + 1;
end

if c-step > 0
    NB(i,1) = a; NB(i,2) = b; NB(i,3) = c-step;
    %i = i + 1;
end
end

