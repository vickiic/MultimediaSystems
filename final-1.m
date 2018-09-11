clear all;
load train_zero.mat
load train_zero2.mat;
load train_one.mat
load train_one2.mat;
load train_two.mat
load train_two2.mat;
load train_three.mat
load train_three2.mat;
load train_four.mat
load train_four2.mat;
load train_five.mat
load train_five2.mat;
load train_six.mat
load train_six2.mat;
load train_seven.mat
load train_seven2.mat;
load train_eight.mat
load train_eight2.mat;
load train_nine.mat
load train_nine2.mat;

%setup codebook
code = cat(2,zero,zero2,one,one2,two,two2,three,three2,four,four2,five,five2,six,six2,seven,seven2,eight,eight2,nine,nine2);

%testFolder should be equal to the name of the folder you're trying to read
testFolder = 'audio';
testFiles = dir(fullfile(testFolder, '*.wav'));
numFiles = length(testFiles);
countCorrect = 0;
countTotal = 0;
output = cell(numFiles,2);

for i=1:numFiles                      % read test sound file of each speaker
    thisfile = fullfile(testFolder, testFiles(i).name );
    [x, fs] = audioread(thisfile);      
    v = mfcc(x, fs);            % Compute MFCC's
    
    %Used to see MFCC plot
    %plot(v);
    %title('Graph of MFCC of Nine');
    %xlabel('MFC coefficients'); % x-axis label
    %ylabel('Amplitude'); % y-axis label
    %pause(2);
    
    distmin = 999;  
    m = 0; % initialize match
    class = 0;
    %compute distortion for each trained codebook
    for l = 1:length(code)      
        dmat = eucdist(v, code{l}); 
        dist = sum(min(dmat,[],2)) / size(dmat,1);
      
        if dist < distmin
            distmin = dist;
            m = l;
            %disp(m);
        end      
    end
    if (m>=1 && m<=35)
        m = 0;
    end 
    if (m>=36 && m<=70)
        m = 1;
    end 
    if (m>=71 && m<=105)
        m = 2;
    end 
    if (m>=106 && m<=140)
        m = 3;
    end 
    if (m>=141 && m<=175)
        m = 4;
    end 
    if (m>=176 && m<=210)
        m = 5;
    end 
    if (m>=211 && m<=242)
        m = 6;
    end 
    if (m>=243 && m<=277)
        m = 7;
    end 
    if (m>=278 && m<=312)
        m = 8;
    end 
    if (m>=313 && m<=347)
        m = 9;
    end 
    
    class = m;
    output(i,1)={testFiles(i).name};
    output(i,2)={class};
    tempName = testFiles(i).name(1:1);
    
    if(str2double(tempName) == m);
        countCorrect = countCorrect + 1;
    end 
    countTotal = countTotal + 1;
    msg = sprintf('file %d matches with digit %d', i, m);
    disp(msg);
end
disp(countCorrect + " Correct Guesses"); 
disp(countTotal + " Total Files");


function dmat = eucdist(x, y)
%read size of both matrices
[M, N] = size(x);
[M2, N2] = size(y); 

%creates new empty matrix using the # of columns from each matrix
dmat = zeros(N, N2);

%put matrix through euclidean distance equation based on which matrix has
%more columns
if (N < N2)
    copies = zeros(1,N2);
    for n = 1:N
        dmat(n,:) = sum((x(:, n+copies) - y) .^2, 1);
    end
else
    copies = zeros(1,N);
    for p = 1:N2
        dmat(:,p) = sum((x - y(:, p+copies)) .^2, 1)';
    end
end

dmat = dmat.^0.5;
end


function c = mfcc(x, fs)
%c  MFCC matrix

% frame size
N = 256;
% inter frame distance
M = 100;

numberOfFrames = 1 + floor((length(x) - N)/double(M));
mat = zeros(N, numberOfFrames); % vector of frame vectors

for i=1:numberOfFrames
    index = 100*(i-1) + 1;
    for j=1:N
        mat(j,i) = x(index);
        index = index + 1;
    end
end

afterWinMat = diag(hamming(N))*mat;
% FFT into freq domain
freqDomMat = fft(afterWinMat);  

%set up filterbank matrix
filterBankMat = MCFFfilterBank(20, N, fs);
%create mel spectrum
ms = filterBankMat*abs(freqDomMat(1:(1 + floor(N/2)),:)).^2; 
c = dct(log(ms));                                
% take out 0'th order cepstral coefficient
c(1,:) = [];                                     
end


function m = MCFFfilterBank(p, n, fs)
%p  number of filters; n  length of fft; fs  sample rate in Hz
%x  filterbank amplitude matrix

lr = log(1 + 0.5/(700/fs)) / (p+1);

% convert to fft bin numbers with 0 for DC term
bl = n * ((700/fs) * (exp([0 1 p p+1] * lr) - 1));

b1 = floor(bl(1)) + 1;
b2 = ceil(bl(2));
b3 = floor(bl(3));
b4 = min(floor(n/2), ceil(bl(4))) - 1;

pf = log(1 + (b1:b4)/n/(700/fs)) / lr;
fp = floor(pf);
pm = pf - fp;

r = [fp(b2:b4) 1+fp(1:b3)];
c = [b2:b4 1:b3] + 1;
v = 2 * [1-pm(b2:b4) pm(1:b3)];

%create sparse matrix with size p x (1+floor(n/2)) that adds elements in v
%that have duplicate subscripts in r and c
m = sparse(r, c, v, p, 1+floor(n/2));
end
