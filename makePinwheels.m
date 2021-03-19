function pinwheels = makePinwheels(sz,interpLev,view)

if nargin < 3
    view = 0;
end

padding = 1;

simData = rand(sz,sz)*2*pi-pi;

A = simData;
A = exp(1i*A);

%create K-space
F = fftshift(fft2(A));

F2 = padarray(A,[padding,padding],0,'both');

A2 = ifft2(ifftshift(F2));
simInterp = angle(A2);

szA2 = size(A2,1);

[X,Y] = meshgrid(linspace(-1,1,szA2));

[Xq,Yq]=meshgrid(linspace(-1,1,szA2*interpLev));

A3=interp2(X,Y,A2,Xq,Yq);

%Smooth with Gaussian
sigma=2;
A3sin = real(A3);
A3cos = imag(A3);
Bsin = imgaussfilt(A3sin,sigma);
Bcos = imgaussfilt(A3cos,sigma);
B = Bsin + 1i*Bcos;

pinwheels = angle(B);

if view
    figure
    imagesc(pinwheels)
    title(['sz: ' num2str(sz) ' padding: ' num2str(padding) ' interpLev' num2str(interpLev)])
    colormap hsv

%     pinwheelsSmall = pinwheels(1:401,1:401);
%     figure
%     imagesc(pinwheelsSmall)
%     title(['sz: ' num2str(sz) ' padding: ' num2str(padding) ' interpLev' num2str(interpLev)])
%     colormap hsv
end

end