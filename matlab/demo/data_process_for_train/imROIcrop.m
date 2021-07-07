function [xMin, xMax, yMin, yMax, zMin, zMax] = imROIcrop(imgT, padLen)

lineX = sum(sum(sum(imgT,4),3),2);
locationNZ = find(lineX);
xMin = locationNZ(1)-padLen;
xMax = locationNZ(end)+padLen;


lineY = sum(sum(sum(imgT,4),3),1);
locationNZ = find(lineY);
yMin = locationNZ(1)-padLen;
yMax = locationNZ(end)+padLen;


lineZ = squeeze(sum(sum(sum(imgT,4),1),2));
locationNZ = find(lineZ);
zMin = locationNZ(1)-padLen;
zMax = locationNZ(end)+padLen;