clear all;
load rms_music.mat
load rms_speech.mat
mean_train_rms_music = mean(rms_music);
mean_train_rms_speech = mean(rms_speech);

% to test new data sets
projectdir = 'audio';
audio_files = dir(fullfile(projectdir, '*.wav'));
allNames = {audio_files.name };

rms_sample = [];
for i = 1:length(audio_files)
 thisfile = fullfile(projectdir, audio_files(i).name );
 rms_sample(i) = find_rms(thisfile);
end

% Euclidean Distance
min_rms = min([min(rms_music), min(rms_speech), min(rms_sample)]);
max_rms = max([max(rms_music), max(rms_speech), max(rms_sample)]);

rms_music = (rms_music - min_rms)/(max_rms - min_rms);
rms_speech = (rms_speech - min_rms)/(max_rms - min_rms);
rms_sample = (rms_sample - min_rms)/(max_rms - min_rms);

% K-Nearest Neighbor Classification: 0 = music, 1 = speech
sample_classification = [];
for i = 1:length(rms_sample)
 for j = 1:length(rms_music)
 d(j) = sqrt((rms_sample(1,i)-rms_music(1,j))^2 + (rms_sample(1,i)-rms_music(1,j))^2 + (rms_sample(1,i)-rms_music(1,j))^2);
end
 for j = 1:length(rms_speech)
 d(j+4) = sqrt((rms_sample(1,i)-rms_speech(1,j))^2 + (rms_sample(1,i)-rms_speech(1,j))^2 + (rms_sample(1,i)-rms_speech(1,j))^2);
 end

 % Find three closest neighbors
 euc_distance = sort(d);
 n1 = find(d == euc_distance(1));
 n2 = find(d == euc_distance(2));
 n3 = find(d == euc_distance(3));
 neighbors = [n1,n2,n3];
  neighbors = find(neighbors <= 4); % If 2 or more neighbors are music, classify as music, else classify as speech
 if (length(neighbors) >= 2)
     disp(0);
 sample_classification(i) = 0;
 else
     disp(1);
 sample_classification(i) = 1;
 end
end

results = [allNames;num2cell(sample_classification)]';

% Results:
music_count = length(find(sample_classification == 0));
speech_count = length(find(sample_classification == 1));
music_percent = music_count / length(sample_classification);
speech_percent = speech_count / length(sample_classification);
disp(['Music Sample Classification: ', num2str(music_percent*100), ' %']);
disp(['Speech Sample Classification: ', num2str(speech_percent*100), ' %']);


% returns percentage of low energy frames in the sample
function [rms] = find_rms(wavfilename)
[x, fs]= audioread(wavfilename);
sample_length = length(x);% find length of wav file
fsize = 0.020; %20ms
flength = round(fs*fsize);% Length of frames
fsec = round(1/fsize); % 50 frames per second
rms = [];
y = 1;
for frame = 1:flength:sample_length-flength
 fdata = x(frame:frame+flength-1);
 % rms value of frame
rms(y) = sqrt(sum(fdata.^2)/length(fdata));
y = y + 1;
end
totalf = length(rms);
% finding number of low energy frames
low = 0;
if (totalf > fsec)
 for i = fsec+1:totalf
 rms_mean(i) = mean(rms(i-fsec:i));
 if (rms(i) < 0.5*rms_mean(i));
 low = low + 1;
 end
 end
end
rms = low/(totalf-fsec);% Result is percentage of low energy frames
end