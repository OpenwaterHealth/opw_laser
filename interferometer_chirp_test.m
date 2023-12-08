clear all;
close all;




mode = 'one';
posVec = [40, 40, 40, 40, 40]; %[421, 321, 221, 121, 40]; %[40, 40, 40, 40, 40]; %
if strcmp(mode, 'one')
        
    data = load ('interferometer_chirp_test.mat');
    TIME_RAW = data.TIME;
    SIGNAL_RAW = data.SIGNAL;

    for i = 1:1
    
    pathDiff = (2 .* (452.35 - posVec(i))) .*1E-3;
    idx_START = find (TIME_RAW > 10E-6, 1, 'first');
    TIME = TIME_RAW(1:end);
    SIGNAL = SIGNAL_RAW(1:end);
    %inputs = [time, signal, breakPoint, MinPeakDistShort, MinPeakDistLong, MinPeakHeightShort, MinPeakHeightLong, pathDiff
    [time1, signal1, FSR] =  peakfit(TIME, SIGNAL, 1.5E-4, 30, 450, 0.056, 0.0695, pathDiff);

    end
  



else
    c = 3E8;   
    lambda_center = 935.8388E-9;
    lambda = linspace(1, 1.00001, 5000) .* lambda_center;
    delta_x = 110E-3;
    y = cos(2*pi./lambda .* delta_x);
    [pks, locs] = findpeaks (y, 'minPeakHeight', 0.9);
    
    figure(3)
    plot(lambda .* 1E9, y, '-')
    hold on;
    plot(lambda(locs).*1E9, pks, '.', 'markersize', 25)
    hold on;
    delta_lambda = diff(lambda(locs));
    delta_frequency = 3E8/(lambda_center).^2 * delta_lambda;
    total_delta_lambda_shift = delta_frequency * 20/1E9;
end

function [fit_time, fit_dLambda, FSR] = peakfit(xIn_raw, yIn_raw, breakPoint, MinPeakDistShort, MinPeakDistLong, MinPeakHeightShort, MinPeakHeightLong, pathDiff)
    idx_startPoint = find (xIn_raw > 0, 1, 'first');
    xIn = xIn_raw(idx_startPoint:end);
    yIn = yIn_raw(idx_startPoint:end);
    wavelength = 935E-9;
    FSR = wavelength.^2/(pathDiff)./1E-9
    figure(1)
    plot(xIn, yIn, '-')
    grid on;
    grid minor;
    xlabel('time(s)');
    ylabel('interferometer signal (V)');
    hold on;
    [yIn_smooth,window] = smoothdata(yIn,"gaussian", 150);
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

    idx_plot = find(time_pks > 10E-6, 1, 'first'); %60E-6  2E-7

    
    delta_time = time_pks(idx_plot:end); % - time_pks(1); %diff(time_pks);
    figure(3)
    delta_lambda = linspace(1, length(delta_time), length(delta_time));
    fit_time = delta_time(1:end-1);
    fit_dLambda = (delta_lambda(1:end-1)-1).* FSR;
    plot((delta_time(1:end-1)), fit_dLambda, '.r', 'markersize', 20)
    grid on;
    grid minor;
    xlabel('time(s)');
    ylabel('\Delta\lambda(nm)');
    hold on;
    

end
function [xOut, yOut] = stitchData(xIn, yIn)
    [yIn_smooth,window] = smoothdata(yIn,"gaussian", 100);
    [pks,locs] = findpeaks(yIn_smooth(floor(length(xIn)/2):end), 'MinPeakHeight', 0.06, 'MinPeakDistance', 1000, 'MinPeakProminence',0.01);
    figure(10)
    plot(xIn, yIn, '-')
    hold on;
end
