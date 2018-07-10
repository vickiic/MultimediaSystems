clear all;  
projectdir = 'audio';
files = dir( fullfile(projectdir, '*.wav') );
numfiles = length(files);
mydata = cell(numfiles,2);

averageCrossRate= 0;
counter=0;
meanAllMax=0;
accuracyMusic=0;
accuracySpeech=0;
a = [];
allNames =[];
allNames = {files.name };

classification =[];
for i = 1 : numfiles
   thisfile = fullfile(projectdir, files(i).name );
   [x, fs] = audioread(thisfile);


ts = 1/fs;
T = (length(x))/fs;
tt = 0+ts:ts:T;
%plot(tt,x);
counter = counter+1;
maxP = .05*max(x);




EmptyAmount = 0;
size = length(x);

%PassZero= 0;

sizez = 0;
totalMax = 0;
lessMax=0;

for (i=2:size-1)
    if (((x(i)>x(i+1))&&(x(i)>x(i-1))||(x(i)<x(i-1)&&(x(i)<x(i+1)))))
        totalMax = totalMax + 1;
        if((abs(x(i)))<maxP)
            lessMax = lessMax + 1;
        end
        
    end 
end
meanMax= (lessMax/totalMax)*100;
b = [meanMax];
a = [a,b];
%disp(meanMax);
if(meanMax>36)
    disp("speech");
    classification(i) = 1;
    accuracySpeech=accuracySpeech + 1;
else 
    disp("music");
    classification(i)=0;
    accuracyMusic=accuracyMusic+1;
end 
meanAllMax = meanAllMax + meanMax;


%Finds the number of times the signal goes from (+ to -) or (- to +)
%disp(PassZero);
%disp(PassZero/(size/30)*100);
%averageCrossRate=averageCrossRate + (PassZero/(size/30)*100);
%Finds the mean of the slope of the entire audio signal
%changeMean = changeMean/size;
%disp(changeMean);



end
meanAllMax = meanAllMax/counter;
results = [allNames;num2cell(classification)]';


disp("meanAllMax is " + meanAllMax);  
disp("percentMusic is "+ (accuracyMusic/counter)*100);
disp("percentSpeech is "+ (accuracySpeech/counter)*100);

sizeS=[1:40];
scatter(sizeS,a,'filled');
xlim([0 40]);
xlabel('File Index');
ylim([0 100]);
ylabel('Percent Empty');
title("Average Percent Empty Per Speech File");

%averageCrossRate = averageCrossRate /counter;
%disp(averageCrossRate);