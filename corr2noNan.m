function [r,p] = corr2noNan(a,b,nanI)

aflat = reshape(a,[],1);
bflat = reshape(b,[],1);

aflat = aflat(~nanI);
bflat = bflat(~nanI);
[r,p] = corr(aflat,bflat);


end