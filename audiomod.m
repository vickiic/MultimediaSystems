function modAudio = audiomod(x,r,fs)
%Change r based on how fast or slow you want the audio to be.
%x input should be the audio signal and fs should be the frequency sample
%you get after you do audioread.

n = 1024;
hop = 256;

% STFT
%invert signal so the row becomes a column and it can be more easily
%modified
x = x';
count = 1;
%Create an empty 2d Array with a size based on the n and hop values
stftArray = zeros((1+n/2),1+fix((length(x)-n)/hop));

for i = 0:hop:(length(x)-n)
  %calculate fast fourier transform for a certain section of audio
  u = n.*x((i+1):(i+n));
  t = fft(u);
  %add the fast fourier transform into the stftArray
  stftArray(:,count) = t(1:(1+n/2))';
  count = count+1;
end

%Synthesis

%find the number of rows and columns in array X
[rows, cols] = size(stftArray);
%create an array consisting values between 0 and the # of columns in
%increments of the inputted rated. 
t = 0:r:(cols-2);
N = 2*(rows-1);
sythesisArray = zeros(rows, length(t));

dA = zeros(1,N/2+1);
dA(2:(1 + N/2)) = (2*pi*hop)./(N./(1:(N/2)));
pT = angle(stftArray(:,1));

stftArray = [stftArray,zeros(rows,1)];
colCount = 1;

%This loop creates the sythesisArray which would have the same number of
%rows as stftArray but a different number of columns 
%(this number is determined by what the r value is)
for tLoop = t
  % Combine two columns
  xcols = stftArray(:,floor(tLoop)+[1 2]);
  % Finds the combined magnitude of the two columns
  tf = tLoop - floor(tLoop);
  combinedMag = (1-tf)*abs(xcols(:,1)) + tf*(abs(xcols(:,2)));
  % Finds the angle difference between the two columns to find phase
  dp = angle(xcols(:,2)) - angle(xcols(:,1)) - dA';
  % Reduces this angle so that it is in the -pi-pi range
  dp = dp - 2 * pi * round(dp/(2*pi));
  % combine magnitude and phase in polar form and add the column to an output array 
  sythesisArray(:,colCount) = combinedMag .* exp(j*pT);
  % Adds up the previous phase for when you loop back around
  pT = pT + dp + dA';
  colCount = colCount+1;
end


%ISTFT
s = size(sythesisArray);
cols = s(2);
w = length(n);
xlen = n + (cols-1)*hop;
%create an empty 1d array with size based on n and hop
istftArray = zeros(1,xlen);

for i = 0:hop:(hop*(cols-1))
  ft = sythesisArray(:,1+i/hop)';
  ft = [ft, conj(ft([((n/2)):-1:2]))];
  %calculate invert fast fourier transform of a portion
  px = real(ifft(ft));
  %add the inverted fast fourier transform into the istftArray
  istftArray((i+1):(i+n)) = istftArray((i+1):(i+n))+px.*n;
end
modAudio = istftArray';
%play altered track
soundsc(modAudio,fs);
%create the new modified audio file
audiowrite('output.wav',modAudio,fs);
end