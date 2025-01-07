clear;clc;close all
warning off
rmpath(genpath('./'));
addpath(genpath('functions_p/'));

%% options
size_downsample = 5000;
size_upsample = [5000];
size_bar = 200;
size_se = 100;
opts_mkmesh = struct('hmax',10,'hmin',10);

tic
%% read image
FileName = 'YOUR/SVS/FILE';
img_rgb = imread(FileName);
figure;imshow(img_rgb);

mn = prod(size(img_rgb,[1,2]));
mnid = find(any(img_rgb,3));
if length(mnid) < 0.95*mn
    for ii = 1:3
    value = img_rgb(mnid);
    img_rgb(:,:,ii) = uint8(255);
    % img_rgb(mnid) = img_tmp(mnid);
    img_rgb(mnid) = value;
    if ii ~= 3
    mnid = mnid + mn;
    end
    end
end
clear mnid value

%% preprocess: image to connected components

% make mask, fill hole and remove small object
sizeimori = size(img_rgb,[1,2]);
ratio = min((size_downsample-1)/min(sizeimori-1),1);
nemptybar = ceil(size_bar/ratio);
img_rgb = cat(1,255*ones(nemptybar,size(img_rgb,2),3,'like',img_rgb),img_rgb);
img_rgb = cat(1,img_rgb,255*ones(nemptybar,size(img_rgb,2),3,'like',img_rgb));
img_rgb = cat(2,255*ones(size(img_rgb,1),nemptybar,3,'like',img_rgb),img_rgb);
img_rgb = cat(2,img_rgb,255*ones(size(img_rgb,1),nemptybar,3,'like',img_rgb));

conns = imbinarize(rgb2gray(img_rgb));  %im_bin ---> conns, just for saving virt

conns = imresize(conns,ratio);
size_re_bin = size(conns);

SE = strel('square',size_se);
conns = imopen(conns,SE);

conns = bwconncomp(~conns);
Areas = cellfun(@length,conns.PixelIdxList);
[Areass,sortid] = sort([Areas,0],'descend');
dA = -diff(Areass);
[~,sharpid] = max(dA);
connsbig = conns.PixelIdxList(sortid(1:sharpid));
nconns = length(connsbig);

fprintf('nCC: %d. \n',nconns)

if nconns == 0
    error('nCC = 0\n');
end

for iconn = 1:nconns
conn = connsbig{iconn};
[F,V] = bw2trimesh2(conn,size_re_bin,size_se,ratio,opts_mkmesh);

%% CEM and SEM to cube
Vsize = size(V,1);
uv = DiskCCEM(F,[V,zeros(size(V,1),1)],500);
TR = triangulation(F,V);
EB = freeBoundary(TR);
Vidxmin = find(uv(:,1) == min(uv(:,1)),1);   Eidxmin = find(EB(:,1) == Vidxmin);
Vidymin = find(uv(:,2) == min(uv(:,2)),1);   Eidymin = find(EB(:,1) == Vidymin);
Vidxmax = find(uv(:,1) == max(uv(:,1)),1);   Eidxmax = find(EB(:,1) == Vidxmax);
Vidymax = find(uv(:,2) == max(uv(:,2)),1);   Eidymax = find(EB(:,1) == Vidymax);
Eid = [Eidxmin,Eidymin,Eidxmax,Eidymax];
[~,k] = min(Eid);
Eid = [Eid(k:end),Eid(1:k-1)];
cubeEid = {EB(Eid(1):Eid(2),1),EB(Eid(2):Eid(3),1),...
           EB(Eid(3):Eid(4),1),[EB(Eid(4):end,1);EB(1:Eid(1),1)]};
       
uvCEM = SquareCEM(F,V,cubeEid);
uvSEM = SquareSEM(F,V,cubeEid,uvCEM);
                                                                                                                                                                                                                                                                                                                                                                           

%% interp
for imRsize = size_upsample
him = 1/(imRsize-1);
X = 0:(imRsize-1);  Y = X;
[X,Y] = meshgrid(X,Y);
X = X(:)/(imRsize-1)*(1-him*2e-3)+him*1e-3;   Y = Y(:)/(imRsize-1)*(1-him*2e-3)+him*1e-3;
Vimg = [X,Y];
clear X Y

% CEM-image
TRCEM = triangulation(F,uvCEM);
imgCEM = trimesh2img(TR,img_rgb,TRCEM,Vimg,imRsize);
figure;imshow(imgCEM);

% SEM-image
TRSEM = triangulation(F,uvSEM);
imgSEM = trimesh2img(TR,img_rgb,TRSEM,Vimg,imRsize);
figure;imshow(imgSEM);

end
end

fprintf('Elapsed time: %.2f s\n',toc);

