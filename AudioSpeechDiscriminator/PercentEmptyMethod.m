clear all;
% Testing new data:
projectdir = 'audio';
audio_files = dir(fullfile(projectdir, '*.wav'));
allNames = {audio_files.name };
sample_classification = [];

% Speech samples:
for i = 1:length(audio_files)
 thisfile = fullfile(projectdir, audio_files(i).name );
 meanMax_sample(i) = find_meanMax(thisfile);
 if(meanMax_sample(i)>36)
    sample_classification(i) = 1;
else 
    sample_classification(i) = 0;
end 
end

results = [allNames;num2cell(sample_classification)]';
disp(results);


function [meanMax] = find_meanMax(wavfilename)
[x, fs] = audioread(wavfilename);
%Threshold to see if the amplitude is low enough to be considered empty
maxP = .05*max(x);

EmptyAmount = 0;
size = length(x);
totalMax = 0;
lessMax=0;

%loop that goes through audio signal 
for (i=2:size-1)
    %if statement checks if the point is a local maximum
    if (((x(i)>x(i+1))&&(x(i)>x(i-1))||(x(i)<x(i-1)&&(x(i)<x(i+1)))))
        totalMax = totalMax + 1;
        %if statement checks if the local maximum is empty
        if((abs(x(i)))<maxP)
            lessMax = lessMax + 1;
        end 
    end 
end

meanMax= (lessMax/totalMax)*100;
end 
