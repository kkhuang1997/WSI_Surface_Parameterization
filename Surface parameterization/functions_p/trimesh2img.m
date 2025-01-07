function imgR = trimesh2img(TRori,imgori,TRpara,Vimg,imRsize)

IDinterp = pointLocation(TRpara,Vimg);
BC = cartesianToBarycentric(TRpara,IDinterp,Vimg);
Vinterp = barycentricToCartesian(TRori,IDinterp,BC);
Vinterp = round(Vinterp);

clear BC

idinterp = sub2ind(size(imgori,[1,2]),Vinterp(:,1),Vinterp(:,2));

clear Vinterp

imgR = [imgori(idinterp),imgori(idinterp + prod(size(imgori,[1,2]))),imgori(idinterp + prod(size(imgori,[1,2]))*2)];
imgR = reshape(imgR,imRsize,imRsize,3);