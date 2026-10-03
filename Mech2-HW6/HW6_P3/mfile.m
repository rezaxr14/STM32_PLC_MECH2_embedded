% --- SAFETY CLEANUP ---
% This ensures the COM port is released even if you close the window early or hit Ctrl+C
cleanupObj = onCleanup(@() closeSerialPort());


s = serialport("COM22", 9600);

% --- SINE WAVE PARAMETERS ---
t = 0:0.05:100; % Time array (runs for a long time so you can watch)
f = 0.2;        % Frequency of the sine wave
% Generate wave: amplitude 511.5, offset by 511.5 to map from 0 to 1023
wave_data = round(511.5 * sin(2*pi*f*t) + 511.5);

% --- UI SETUP ---
fig = figure('Name', '10-bit PWM Transmission');
keepRunning = true;

% Create a STOP button on the graph to gracefully exit the loop
btn = uicontrol('Style', 'pushbutton', 'String', 'STOP TRANSMISSION', ...
    'Position', [20 20 150 30], ...
    'Callback', 'keepRunning = false;'); 

hold on; title('Sending 10-bit Sine Wave to Proteus (7-Bit Encoded)');
xlabel('Time'); ylabel('Duty Cycle (0-1023)');

% --- TRANSMISSION LOOP ---
i = 1;
while keepRunning && i <= length(wave_data)
    
    val = wave_data(i);
    
    % The 7-Bit Encoding
    high_byte = bitshift(val, -7) + 128;
    low_byte = bitand(val, 127);
    
    % 1. Send High Byte first
    write(s, high_byte, "uint8");
    
    pause(0.01); 
    
    % 3. Send Low Byte
    write(s, low_byte, "uint8");
    
    % Live plotting
    plot(t(1:i), wave_data(1:i), 'b-', 'LineWidth', 2);
    axis([0 max(t) 0 1100]);
    drawnow;
    
    % Delay before the next complete cycle
    pause(0.05); 
    i = i + 1;
end



disp('Transmission Complete or Stopped by User.');

% --- HELPER FUNCTION ---
% This function is called automatically when the script ends or is stopped
function closeSerialPort()
    % Find all open serial ports and close them to prevent "Port in use" errors
    portList = serialportlist;
    if ~isempty(portList)
        clear s;
    end
    disp('COM Port closed safely and is ready for the next run.');
end