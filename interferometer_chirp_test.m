%% **************************************************************************************************
% * This code read the interferometer signal data from the file "interferometer_chirp_test.mat"     *
% * smooth the inteferometer signal, find the peaks' locations, calculateFSR for the given path     *
% * difference (adjustable mirror position) and calculate the chirp infrequency in the pulse width  *
%%***************************************************************************************************

clear all;
close all;




mode = 'chirp'; % enter the FSR for FSR simulation and chirp for chirp test
posVec = 40; 
if strcmp(mode, 'chirp')
        
    data = load ('interferometer_chirp_test.mat');
    TIME_RAW = data.TIME;
    SIGNAL_RAW = data.SIGNAL;

    for i = 1:1
    
    pathDiff = (2 .* (452.35 - posVec)) .*1E-3;
    idx_START = find (TIME_RAW > 10E-6, 1, 'first');
    TIME = TIME_RAW(1:end);
    SIGNAL = SIGNAL_RAW(1:end);
    %inputs = [time, signal, breakPoint, MinPeakDistShort, MinPeakDistLong, MinPeakHeightShort, MinPeakHeightLong, pathDiff
    [time1, signal1, FSR] =  peakfit(TIME, SIGNAL, 1.5E-4, 30, 450, 0.056, 0.0695, pathDiff);
    end
  

else
    c = 3E8;   
    lambda_center = 935.8388E-9; %
    lambda = linspace(0.99997, 1.0000, 5000) .* lambda_center;
    posVec = [420, 370, 320];
    for i = 1:3
        delta_x = (2 .* (452.35 - posVec(i))) .* 1E-3;
        y = 2 - 2 .* cos(2*pi./lambda .* delta_x);
        y_normalized = (y./max(y)).^2;
        [pks, locs] = findpeaks (y_normalized, 'minPeakHeight', 0.9);
        lambda_locs = lambda(locs) .* 1E9;
        figure(i)
        plot(lambda .* 1E9, y_normalized, '-', 'linewidth', 2)
        hold on;
        plot(lambda_locs, pks, '.', 'markersize', 35)
        xline(lambda_locs(1), '--','linewidth', 2);
        xline(lambda_locs(2), '--', 'linewidth',2);
        xlabel('\lambda(nm)');
        ylabel('interference signal-normalized')
        ylim([0,1.1]);
        hold on;
        grid on;
        grid minor;
        delta_lambda = lambda_locs(2) - lambda_locs(1)
%         delta_frequency = 3E8/(lambda_center).^2 * delta_lambda;
%         total_delta_lambda_shift = delta_frequency * 20/1E9;
    end
end

function [fit_time, fit_dLambda, FSR] = peakfit(xIn_raw, yIn_raw, breakPoint, MinPeakDistShort, MinPeakDistLong, MinPeakHeightShort, MinPeakHeightLong, pathDiff)
    idx_startPoint = find (xIn_raw > 10E-6, 1, 'first');
    xIn = xIn_raw(idx_startPoint:end);
    yIn = yIn_raw(idx_startPoint:end);
    wavelength = 935E-9;
    FSR = wavelength.^2/(pathDiff)./1E-9;
    figure(1)
    plot(xIn, yIn, '-')
    grid on;
    grid minor;
    xlabel('time(s)');
    ylabel('interferometer signal (V)');
    hold on;
    [yIn_smooth] = smoothdata(yIn,"gaussian", 150);
    plot(xIn, yIn_smooth, '-')
    hold on;
    idx_first_segment = find(xIn < breakPoint, 1,'last');
    
    [pks_segment_first,locs_segment_first] = findpeaks(yIn_smooth(1:idx_first_segment), 'MinPeakHeight', MinPeakHeightShort,'MinPeakDistance',MinPeakDistShort);
    
    [pks_segment_last,locs_segment_last] = findpeaks(yIn_smooth(idx_first_segment:end), 'MinPeakHeight', MinPeakHeightLong,'MinPeakDistance',MinPeakDistLong);
    
    time_segment_first = xIn(locs_segment_first);
    time_segment_last = xIn(idx_first_segment + locs_segment_last);
    time_pks = [time_segment_first; time_segment_last];
    pks = [pks_segment_first; pks_segment_last];
    plot(time_pks, pks, '.', 'markersize', 20)
    hold on;


    delta_time = time_pks(1:end); % - time_pks(1); % - time_pks(1); %diff(time_pks);
    figure(3)
    delta_lambda = linspace(1, length(delta_time), length(delta_time));
    fit_time = delta_time(1:end-1); %delta_time(1:end-1);
    fit_dLambda = (delta_lambda(1:end-1)-1).* FSR;
    plot((fit_time), fit_dLambda, '.r', 'markersize', 20)
    grid on;
    grid minor;
    xlabel('time(s)');
    ylabel('\Delta\lambda(nm)');
    hold on;

    tq = 0:1E-6: 1.6E-3;
    sp = pchip(fit_time, fit_dLambda, tq);
    plot(tq(100:end), sp(100:end), '--', 'linewidth', 2);
    hold on;
    idx_1p5ms = find(tq > 1.5E-3, 1, 'first');
    sp(idx_1p5ms);
    plot(tq(idx_1p5ms), sp(idx_1p5ms), '.b', 'markersize', 35)
    hold on;
    yline(sp(idx_1p5ms), '--', 'linewidth', 2);
    

end

