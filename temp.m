% calcDist.m
%
%	$Id: calcDist.m 1404 2009-02-17 00:37:15Z justin $	
%      usage: calcDist()
%         by: eli merriam
%       date: 11/28/07
%    purpose: 
%
function retval = calcDist(view, method)

% check arguments
if ~any(nargin == [1 2])
  help calcDist
  return

end
retval = [];
if ieNotDefined('method'); method = 'pairs'; end


% baseCoords contains the mapping from pixels in the displayed slice to
% voxels in the current base volume.
baseCoords = viewGet(view,'cursliceBaseCoords');
if isempty(baseCoords)
  mrWarnDlg('Load base anatomy before drawing an ROI');
  return;
end

% get the base CoordMap for the current flat patch
corticalDepth = viewGet(view, 'corticalDepth');
baseCoordMap = viewGet(view,'baseCoordMap');
baseHdr = viewGet(view, 'basehdr');

if isempty(baseCoordMap)
  mrWarnDlg('(calcDist) You cannot use this function unless you are viewing a flatpatch with a baseCoordMap');
  return;
end
disp('(calcDist) Draw line segments for which you want to compute the distance of. Click to add a point. Double-click to end making line segments');
if strcmp(method, 'roi')
  disp(sprintf('(calcDist) ROI method not implemented'));
else
  % Select main axes of view figure for user input
  fig = viewGet(view,'figNum');
  gui = guidata(fig);
  set(fig,'CurrentAxes',gui.axis);
  
  % pick some points
  [xi yi] = getpts;

  % draw the lines temporarily
  polyIm = roipoly(a,xi,yi);

  baseX = baseCoords(:,:,1);
  baseY = baseCoords(:,:,2);
  baseZ = baseCoords(:,:,3);
  polyImIndices = find(polyIm);
  x = baseX(polyImIndices);
  y = baseY(polyImIndices);
  z = baseZ(polyImIndices);
  coords = [x'; y'; z'; ones(1,length(x))];
  
end

disp('(calcDist) Computing distance');

% load the appropriate surface files
disp(sprintf('Loading %s', baseCoordMap.innerCoordsFileName));
%%% ATTN: load the surface here %%
surf.inner = loadSurfOFF(fullfile(baseCoordMap.path, baseCoordMap.innerCoordsFileName));
if isempty(surf.inner)
  mrWarnDlg(sprintf('(calcDist) Could not find surface file %s',fullfile(baseCoordMap.path, baseCoordMap.innerCoordsFileName)));
  return
end
%%% ATTN: need to transform to Array coordinates %%
surf.inner = xformSurfaceWorld2Array(surf.inner, baseHdr);

disp(sprintf('Loading %s', baseCoordMap.outerCoordsFileName));
surf.outer = loadSurfOFF(fullfile(baseCoordMap.path, baseCoordMap.outerCoordsFileName));
if isempty(surf.outer)
  mrWarnDlg(sprintf('(calcDist) Could not find surface file %s',fullfile(baseCoordMap.path, baseCoordMap.outerCoordsFileName)));
  return
end
surf.outer = xformSurfaceWorld2Array(surf.outer, baseHdr);

% build up a mrMesh-style structure, taking account of the current corticalDepth
%%% ATTN: you do need to create the mesh structure because of naming conventions
mesh.vertices = surf.inner.vtcs;
mesh.faceIndexList  = surf.inner.tris;

% calculate the connection matrix
%%% ATTN: I think you need to do this too
[mesh.uniqueVertices,mesh.vertsToUnique,mesh.UniqueToVerts] = unique(mesh.vertices,'rows'); 
mesh.uniqueFaceIndexList = findUniqueFaceIndexList(mesh); 
mesh.connectionMatrix = findConnectionMatrix(mesh);

% get the coordinates of the vertices that are closest to the selected points
%%% ATTN: you need to do this
[nearestVtcs, distances] = assignToNearest(mesh.uniqueVertices, coords);

% complain if any of the selected points are far away
for i=1:length(distances)
  if (distances>1)
    disp(sprintf('(calcDist) Point %i is %f from the nearest surface vertex', i, distances(i)));
  end
end

% find the distance of all vertices from their neighbours
%% you need to do this 
scaleFactor = [1 1 1];
D = find3DNeighbourDists(mesh,scaleFactor); 

retval = [];
switch lower(method)
  case {'segments'}
    % calculate length of each segment (1-2, 2-3, 3-4)
    for p=1:length(nearestVtcs)-1
      %%% ATTN: this is the heart of what you are doing.
      %%% dist will be the distance between the input coords and every other vertex
      dist = dijkstra(D, nearestVtcs(p))';
      retval(p) = dist(nearestVtcs(p+1));
    end 
 case {'pairs'}
    % calculate lengths of a bunch of pairs (1-2, 3-4, 5-6)
    for p=1:2:length(nearestVtcs)
      dist = dijkstra(D, nearestVtcs(p))';
      retval(end+1) = dist(nearestVtcs(p+1));
    end
  case {'roi'}
    % calculate lengths of each point from the first coordinate
    dist = dijkstra(D, nearestVtcs(1))';
    retval = dist(nearestVtcs);
  otherwise
    mesh.dist = dijkstra(D, nearestVtcs(1))';
end

if nargout == 1
  retval = dist(nearestVtcs);
end

keyboard;

patch('vertices', mesh.uniqueVertices, 'faces', mesh.uniqueFaceIndexList,'FaceVertexCData', mesh.dist,'facecolor', 'interp','edgecolor', 'none');

return;


% patch('vertices', mesh.uniqueVertices, 'faces', mesh.uniqueFaceIndexList, ...
%       'FaceVertexCData', mesh.dist, ...
%       'facecolor', 'interp','edgecolor', 'none');


% baseX = zeros(1,length(xi));
% baseY = zeros(1,length(xi));
% baseZ = zeros(1,length(xi));
% for p=1:length(xi)
%   baseX(p) = baseCoordMap.innerCoords(xi(p), yi(p), 1, 1);
%   baseY(p) = baseCoordMap.innerCoords(xi(p), yi(p), 1, 2);
%   baseZ(p) = baseCoordMap.innerCoords(xi(p), yi(p), 1, 3);
% end

% coords = [baseX' baseY' baseZ'];



