function [P] = vidToGif(videoName)
vid=VideoReader(videoName);
 numFrames = vid.NumberOfFrames;
 n=numFrames;
 
for i = 11:2:n+10
 frames = read(vid,i-10);
 imwrite(frames,['Image' int2str(i), '.jpg']);
 im(i)=image(frames);
end

photoName = string(zeros(1,n/2));
 for i = 1:n/2
     photoName(i)= "Image" +int2str(9+(i*2))+ ".jpg";
 end

photoName=sort(photoName);
[gifName gifPath]=uiputfile('*.gif');
loops=65535;
delay= 0.1;
for i=1:length(photoName)
    if strcmpi('gif',photoName{i}(end-2:end))
        [M  c]=imread([gifPath,photoName{i}]);
        
    else
        a=imread([gifPath,photoName{i}]);
        RGB_1 = [255 133 114];
        RGB_1 = RGB_1 ./ 255;
        cartoon = bilateral(a, 3);
        cartoon = edges(cartoon, 3);
        gray = rgb2gray(cartoon);
        BIN = gray > 0.5;
        grayImage = uint8(255 * BIN);

% Fill white with user-chosen colors
        a = cat(3, grayImage * RGB_1(1), grayImage * RGB_1(2), grayImage * RGB_1(3));
        [M  c]= rgb2ind(a,256);
    end
    if i==1
        imwrite(M,c,[gifPath,gifName],'gif','LoopCount',loops,'DelayTime',delay)
    else
        imwrite(M,c,[gifPath,gifName],'gif','WriteMode','append','DelayTime',delay)
    end
end
P='Done';
end


function[Edge] = edges(B, levels)
    maxthresh = 0.2;
    sharpness = [0.75 5.0];
    minEdge = 0.3;
    noLevel = levels;
    
    [GradientX, GradientY] = gradient(B(:,:,1)/100);
    GradientS = sqrt(GradientX.^2 + GradientY.^2);
    GradientS(GradientS > maxthresh) = maxthresh;
    GradientS = GradientS / maxthresh;
    SharpV = diff(sharpness)*GradientS+sharpness(1);
    cB = B; 
    dq = 100/(noLevel-1);
    cB(:,:,1) = (1/dq)*cB(:,:,1);
    cB(:,:,1) = dq*round(cB(:,:,1));
    cB(:,:,1) = cB(:,:,1)+(dq/2)*tanh(SharpV.*(B(:,:,1)-cB(:,:,1)));
    Edge = GradientS; %edge map
    Edge(Edge < minEdge) = 0;
    Edge = repmat(1-Edge,[1 1 3]).*lab2rgb(cB);
    
end

function[B] = bilateral(A, passes)
    A = rgb2lab(A);
    A = im2double(A);
    sigd = 3;
    sigr = 10;
    w = 5;
    [X,Y] = meshgrid(-w:w, -w:w);% Gaussian domain weights
    G = exp(-(X.^2 + Y.^2)/(2 * sigd^2));
    dd = size(A);
    B = zeros(dd);
    for k = 1:passes
        for i = 1:dd(1)
           for j = 1:dd(2)
                 iMin = max(i-w, 1);
                 iMax = min(i+w, dd(1));
                 jMin = max(j-w, 1);
                 jMax = min(j+w, dd(2));
                 I = A(iMin:iMax,jMin:jMax,:);
                 dL = I(:,:,1)-A(i,j,1);
                 da = I(:,:,2)-A(i,j,2);
                 db = I(:,:,3)-A(i,j,3);
                 H = exp(-(dL.^2+da.^2+db.^2)/(2*sigr^2));
                 F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1); % Calculate bilateral filter response
                 normf = sum(F(:));
                 B(i,j,1) = sum(sum(F.*I(:,:,1)))/normf;
                 B(i,j,2) = sum(sum(F.*I(:,:,2)))/normf;
                 B(i,j,3) = sum(sum(F.*I(:,:,3)))/normf;
                 
           end
        end
        A = B;
    end
end