clear
clc 
close all

%% Declare varibles
n = 25; %number of signals
m = 5e3;
count=0;
debug=0;
%% Loop through data

for i=1:n
sig = load(sprintf('datasensor%d.csv',i));
sig = sig(:,3); % acceleration in z axis
sig2 = sig;
sig = medfilt1(sig,80);

%% Plot original and filtered signal
if (debug == 1)
    figure
    hold on
    plot(sig2, 'r')
    plot(sig)
    legend('Original','Filtered')
    xlabel('Time [s]');
    ylabel('Acceleration [m/s^2]');
end

%% Determine peaks and dips
thresh = 6; % peak > thresh
thresh_i = 180; % dist between peaks > thresh_i
x = 0:length(sig)-1; %time vector
[pks,locs]=findpeaks(sig,x,'MinPeakDistance',thresh_i); %find peaks in signal
j=1;
    %% see if peak is > tresh
    for k = 1:length(pks)
        if pks(k) > thresh
            pks_new(j) = pks(k);
            locs_new(j) = locs(k);
            j = j+1; 
        end
    end
    %% find dips in peak
    for k = 1:length(pks_new)-1
        [dip(k),loc_dip(k)] = min(sig(locs_new(k):locs_new(k+1))); %find dips
        loc_dip(k) = loc_dip(k)+ locs_new(k);
        
        %% Plot dips and peaks
        if (debug == 1)
           figure
%%         plot(sig2)
           hold on
           plot(locs_new,pks_new,'r*')
           plot(loc_dip,dip,'go')
           plot(sig,'r');
        end
    end
    
    if (debug == 1)
         figure
         plot(sig2)
         hold on
         plot(locs_new,pks_new,'r*')
         plot(loc_dip,dip,'go')
         plot(sig,'r')
    end
         
    %% Split signal into peaks
    for k = 1:length(loc_dip)-1
        count=count+1;
        sig_split = sig(loc_dip(k):loc_dip(k+1));
        a = m/length(sig_split);
        [p,q] = rat(a);
        q = round(q);
        sig_split = resample(sig_split,p,q);
        sig_split = sig_split(1:m-100);
        
        %x = 0:length(sig_split)-1;
        %p2 = polyfit(x',sig_split,2);
        %y3 = polyval(p2,x);
        A(:,count) = sig_split;
        
    end
    

end

figure
plot(sum(abs(A),2)/160,'linewidth',1.5)
xlabel('time [t]')
ylabel('SMA')

meanv = mean(A,2);

%% Make std-vector
stdv = std(A,0,2);
%%
figure
Fs=0.001
t=0:Fs:length(sig_split)*Fs-Fs;
plot(t,A(:,n),'Linewidth',2)
hold on
plot(t,meanv,'g*')
plot(t,meanv+2*stdv,'r*')
plot(t,meanv-2*stdv,'r*')
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');


% figure
% plot(sig)
% hold on
% plot(locs_new,pks_new,'g*')
% plot(loc_dip,dip,'ro')
% 
% figure
% normplot(sig_split)
% 
% figure
% cdfplot(sig(loc_dip(1):loc_dip(2)))
% 
% 



