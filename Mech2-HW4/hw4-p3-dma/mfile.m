clear; clc;

PORT_NAME = 'COM2';
BAUD_RATE = 9600;

SAMPLES_PER_CYCLE = 1024;
CYCLES_TO_GET = 9;
TOTAL_SAMPLES = SAMPLES_PER_CYCLE * CYCLES_TO_GET;

if ismember(PORT_NAME, serialportlist("available"))
    oldPort = serialportfind("Port", PORT_NAME);
    if ~isempty(oldPort)
        delete(oldPort);
    end
end

try
    serialObj = serialport(PORT_NAME, BAUD_RATE);
    serialObj.Timeout = 2;
catch ME
    error('Connection failed: %s', ME.message);
end

buffer = zeros(1, TOTAL_SAMPLES, 'uint8');
samplesReceived = 0;

fig = figure;
ax = axes('Parent', fig);
plotHandle = plot(ax, NaN, NaN, 'b-');
xlabel(ax, 'Sample Number');
ylabel(ax, 'Value (0-255)');
title(ax, sprintf('Collecting %d samples', TOTAL_SAMPLES));
grid(ax, 'on');
axis(ax, [0 TOTAL_SAMPLES 0 260]);

flush(serialObj);

while samplesReceived < TOTAL_SAMPLES
    if ~isgraphics(fig)
        break;
    end
    if serialObj.NumBytesAvailable > 0
        toRead = min(serialObj.NumBytesAvailable, TOTAL_SAMPLES - samplesReceived);
        newData = read(serialObj, toRead, "uint8");
        if ~isempty(newData)
            startIdx = samplesReceived + 1;
            endIdx = samplesReceived + length(newData);
            buffer(startIdx:endIdx) = newData;
            samplesReceived = endIdx;
            set(plotHandle, 'XData', 1:samplesReceived, 'YData', buffer(1:samplesReceived));
            drawnow limitrate;
        end
    else
        pause(0.01);
    end
end

if samplesReceived >= TOTAL_SAMPLES
    fprintf('Acquisition complete.\n');
elseif isgraphics(fig)
    fprintf('Stopped early: %d of %d samples received.\n', samplesReceived, TOTAL_SAMPLES);
end

if isgraphics(fig)
    title(ax, sprintf('Final plot - %d samples', samplesReceived));
    set(plotHandle, 'XData', 1:samplesReceived, 'YData', buffer(1:samplesReceived));
    axis(ax, [0 samplesReceived 0 260]);
else
    if samplesReceived > 0
        figure;
        plot(1:samplesReceived, buffer(1:samplesReceived), 'r-');
        xlabel('Sample Number');
        ylabel('Value (0-255)');
        title(sprintf('Data from STM32 (%d samples)', samplesReceived));
        grid on;
        axis([0 samplesReceived 0 260]);
    end
end

if exist('serialObj', 'var')
    clear serialObj;
end