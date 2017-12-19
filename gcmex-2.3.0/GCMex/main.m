close all;
clear;

img1 = im2double(imread('./../../family/3.JPG'));
img2 = im2double(imread('./../../family/4.JPG'));
img3 = im2double(imread('./../../family/5.JPG'));
img4 = im2double(imread('./../../family/1.JPG'));
img5 = im2double(imread('./../../family/2.JPG'));

nbImg = 20;

mask1 = im2double(imread('./../../family/mask1.png'));
mask2 = im2double(imread('./../../family/mask2.png'));
mask3 = im2double(imread('./../../family/mask3.png'));
mask4 = im2double(imread('./../../family/mask4.png'));
mask5 = im2double(imread('./../../family/mask5.png'));

[Hb, Wb, Cb] = size(img1);

imgs = zeros(nbImg, Hb, Wb, Cb);
imgs(1, :, :, :) = img1;
imgs(2, :, :, :) = img2;
imgs(3, :, :, :) = img3;
imgs(4, :, :, :) = img4;
imgs(5, :, :, :) = img5;

overlap = 30;

masks = zeros(nbImg, Hb, Wb, Cb);
masks(1, :, :, :) = mask1;
masks(2, :, :, :) = mask2;
masks(3, :, :, :) = mask3;
masks(4, :, :, :) = mask4;
masks(5, :, :, :) = mask5;

% patch1 = squeeze(imgs(1, :, :, :).*masks(1, :, :, :));
% patch2 = squeeze(imgs(2, :, :, :).*masks(2, :, :, :));
patch3 = squeeze(imgs(3, :, :, :).*masks(3, :, :, :));
patch4 = squeeze(imgs(4, :, :, :).*masks(4, :, :, :));
% patch5 = squeeze(imgs(5, :, :, :).*masks(5, :, :, :));

% imagesc(patch1 + patch2 + patch3 + patch4 + patch5);

[H, W, C] = size(patch3);

% mask3 = squeeze(mask3(:,:,1));
indiceW = find(mask3);
tmpIndice = indiceW(1);

x = fix(tmpIndice/H) + 1;
y = mod(tmpIndice, H);

tmpPatch3 = patch3;

tmpPatch3(all(all(tmpPatch3 == 0,3),2),:,:) = [];
tmpPatch3(:,all(all(tmpPatch3 == 0,3),1),:) = [];

[H3, W3, C3] = size(tmpPatch3);

tmpMask = zeros(H, W, C);
tmpMask(y:y+H3-1, x+W3:x+W3+W3-1, :) = 1;

se = strel('cube', overlap);
mask3 = imdilate(mask3, se);

se = strel('cube', overlap);
tmpMask = imdilate(tmpMask, se);
 
patch3 = squeeze(imgs(3, :, :, :)).*mask3;

patch4 = squeeze(imgs(4, :, :, :)).*tmpMask;

blockR = patch4;
blockL = patch3;

blockR(blockR<0) = 0;

blockL(all(all(blockL == 0,3),2),:,:) = [];
blockL(:,all(all(blockL == 0,3),1),:) = [];

blockR(all(all(blockR == 0,3),2),:,:) = [];
blockR(:,all(all(blockR == 0,3),1),:) = [];

res = graphcut(blockL, blockR, overlap);
