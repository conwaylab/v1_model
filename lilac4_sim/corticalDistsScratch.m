surfDir = 'T:/users/singhsr/MEG_Project2018/MRI/my_recons/lilac4/surf/';
surfRelaxDir = 'T:/users/singhsr/MEG_Project2018/MRI/my_recons/lilac4/surfRelax/';
freeSurfer2off([surfDir 'lh.lh_sub.pial'],[surfRelaxDir 'lilac4_lh_subdivide.off']);

surf.inner = loadSurfOFF(fullfile(surfRelaxDir,'lilac4_lh_subdivide.off'));
load('flatmapV1_highres.mat')
coords2D = squeeze(bflat.coordMap.coords);
coords = reshape(coords2D,[],3);
surf.inner = xformSurfaceWorld2Array(surf.inner, bhdr);

mesh.vertices = surf.inner.vtcs;
mesh.faceIndexList  = surf.inner.tris;

% calculate the connection matrix
[mesh.uniqueVertices,mesh.vertsToUnique,mesh.UniqueToVerts] = unique(mesh.vertices,'rows'); 
mesh.uniqueFaceIndexList = findUniqueFaceIndexList(mesh); 
mesh.connectionMatrix = findConnectionMatrix(mesh);

[nearestVtcs, distances] = assignToNearest(mesh.uniqueVertices, coords);

scaleFactor = [1 1 1];
D = find3DNeighbourDists(mesh,scaleFactor); 

ind = sub2ind([401,401],163,17)
dist = dijkstra(D, nearestVtcs(ind))';

corticalDist = 0.45;
thresh = 0.04;
closestVtcs = find(abs(dist-corticalDist)<thresh);
find(nearestVtcs == closestVtcs(3))

%%
load('retinotopyMaps_sz_401.mat')
isV1 = ~isnan(flatRetinotopy.eccen);
isV1 = reshape(isV1,[],1);
v1Inds = find(isV1);
v1Dists = sparse(sum(isV1),sum(isV1));

for i = 1:sum(isV1)
    v1Ind1 = v1Inds(i);
    vert1 = nearestVtcs(v1Ind1);
    dist = dijkstra(D, vert1)';
    for j = 1:i
        v1Ind2 = v1Inds(j);
        vert2 = nearestVtcs(v1Ind2);
        v1Dists(i,j) = dist(vert2);
    end
end