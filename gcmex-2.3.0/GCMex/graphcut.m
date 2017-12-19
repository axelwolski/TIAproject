function target = graphcut(srcA, srcB, overlap)

heightA = size(srcA,1);
widthA = size(srcA,2);

target = zeros(heightA, widthA*2-overlap, 3);

figure(1)
imagesc(target);

sizeT = size(target);
target(:, 1:widthA, :) = srcA;
target(:, widthA+1-overlap:sizeT(2), :) = srcA;

blockR = srcA(:,widthA-overlap+1:widthA,:);
[H, W, D] = size(blockR);
blockL = srcB(:,1:overlap,:);

N = H * W;
CLASS = zeros(N,1); %vecteur 1xtaille H*W par rapport a la taille de l'overlap, permet de définir les labels de chaque noeux du graph

nbClass = 2; %Nombres de patch utilisé pour la fusion

UNARY = zeros(nbClass, N); %le data term correspondant à chaque noeud
PAIRWISE = sparse(N,N); %poid de chaque pixel par rapport a ses voisins
LABELCOST = [0,1 ; 1,0];
tmpMask = zeros(H,W);

for row = 0:H-1
  for col = 0:W-1
    pixel = 1+ row*W + col;
    tmpMask(row+1, col+1) = pixel;
    if (row+1 < H)
        PAIRWISE(pixel, 1+col+(row+1)*W) = poid([row+1 col+1],[row+2 col+1],blockL,blockR);
    end
    if (row-1 >= 0)
        PAIRWISE(pixel, 1+col+(row-1)*W) = poid([row+1 col+1],[row col+1],blockL,blockR); 
    end 
    if (col+1 < W)
        PAIRWISE(pixel, 1+(col+1)+row*W) = poid([row+1 col+1],[row+1 col+2],blockL,blockR);
    else
        UNARY(:,pixel) = [0 1000]'; 
    end
    if (col-1 >= 0)
        PAIRWISE(pixel, 1+(col-1)+row*W) = poid([row+1 col+1],[row+1 col],blockL,blockR); 
    else
        UNARY(:,pixel) = [1000 0]'; 
    end
  end
end

[labels E Eafter] = GCMex(CLASS, single(UNARY), PAIRWISE, single(LABELCOST),0);

fprintf('E: %d (should be 260), Eafter: %d (should be 44)\n', E, Eafter);
fprintf('unique(labels) should be [0 4] and is: [');
fprintf('%d ', unique(labels));
fprintf(']\n');


labelsId = labels .* (1:N)';

maskA = ismember(tmpMask,labelsId);
maskB = ones(H,W) - maskA;

res1 = (maskA .* blockR(:,:,1)) + (maskB .* blockL(:,:,1));
res2 = (maskA .* blockR(:,:,2)) + (maskB .* blockL(:,:,2));
res3 = (maskA .* blockR(:,:,3)) + (maskB .* blockL(:,:,3));
res = zeros(H,W,D);
res(:,:,1) = res1;
res(:,:,2) = res2;
res(:,:,3) = res3;


target(:,1:widthA,:) = srcA;
target(:,end-widthA+1:end,:) = srcB;
target(:,widthA-overlap+1:widthA,:) = res;

figure(1)
imagesc(target);

end
