clear all;
load zcr_speech.mat
load zcr_music.mat
mean_zcr_music = mean(zcr_music);
mean_zcr_speech = mean(zcr_speech);

% Testing new data:
projectdir = 'audio';
audio_files = dir(fullfile(projectdir, '*.wav'));
allNames = {audio_files.name };
zcr_samples = [];
for i = 1:length(audio_files)
  thisfile = fullfile(projectdir, audio_files(i).name );
  zcr_samples(i) = find_zcr(thisfile);
end

% Euclidean distances:
min_zcr = min([min(zcr_music), min(zcr_speech), min(zcr_samples)]);
max_zcr = max([max(zcr_music), max(zcr_speech), max(zcr_samples)]);
zcr_music = (zcr_music - min_zcr)/(max_zcr - min_zcr);
zcr_speech = (zcr_speech - min_zcr)/(max_zcr - min_zcr);
zcr_samples = (zcr_samples - min_zcr)/(max_zcr - min_zcr);

% 3-Nearest Neighbor 0 = music 1= speech
sample_classification = [];
for i = 1:length(zcr_samples)
 for j = 1:length(zcr_music)
 d(j) = sqrt((zcr_samples(1,i)-zcr_music(1,j))^2 + (zcr_samples(1,i)-zcr_music(1,j))^2 + (zcr_samples(1,i)-zcr_music(1,j))^2);
 end
 
 for j = 1:length(zcr_speech)
 d(j+4) = sqrt((zcr_samples(1,i)-zcr_speech(1,j))^2 + (zcr_samples(1,i)-zcr_speech(1,j))^2 + (zcr_samples(1,i)-zcr_speech(1,j))^2);
 end
 % Find three closest neighbors
 euc_distance = sort(d);
 n1 = find(d == euc_distance(1));
 n2 = find(d == euc_distance(2));
 n3 = find(d == euc_distance(3));
 neighbors = [n1,n2,n3];
 
 % If 2 or more neighbors are music, classify as music
 % else classify as speech
 neighbors = find(neighbors <= 4);
    if (length(neighbors) >= 2);
    disp(0); %output 0 on command window
 sample_classification(i) = 0;% music
    else
 disp(1);
 sample_classification(i) = 1;% speech
    end
end
 
results = [allNames;num2cell(sample_classification)]';

% Calculate results:
music_count = length(find(sample_classification == 0));
speech_count = length(find(sample_classification == 1));
music_percent = music_count / length(sample_classification);
speech_percent = speech_count / length(sample_classification);
disp(['Music Percentage: ', num2str(music_percent*100), ' %']);
disp(['Speech Percentage: ', num2str(speech_percent*100), ' %']);



function [zcr] = find_zcr(wavfilename)
[x, fs]= audioread(wavfilename);
slength = length(x);%sample length
% Length of frame
fsize = 0.020;
flength = round(fs*fsize);
f_sec = round(1/fsize) ;% frames per second
% Calculate number of zero-crossings in each frame
zcr = [];
y = 1;
for frame = 1:flength:slength-flength
 fdata = x(frame:frame+flength-1);
 % Sum up zero crossings accross frame
 zcr(y) = 0;
 for i = 2:length(fdata)
 zcr(y) = zcr(y) + abs(sign(fdata(i)) - sign(fdata(i-1)));
 end
 zcr(y) = zcr(y)/(2*flength);
 y = y + 1;
end
totalf = length(zcr);
% Calculate variance in zero-crossing rate
if (totalf > f_sec)
 z =1;
 for j = f_sec+1:totalf
 stdz(z) = std(zcr(j-f_sec:j));
 z = z + 1;
 end
end
% Result = mean variance in zero crossing rate
zcr = mean(stdz);
end