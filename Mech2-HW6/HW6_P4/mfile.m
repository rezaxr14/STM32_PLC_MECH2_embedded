clear;
% --- SAFETY CLEANUP ---
% Ensures the COM port is released even if you close the window early
cleanupObj = onCleanup(@() closeSerialPort());

% --- SERIAL PORT SETUP ---
% Change "COM1" to the port MATLAB is using in your virtual pair (e.g., COM1)
s = serialport("COM22", 9600);
configureTerminator(s, "LF"); % Set standard newline terminator for clean parsing

% --- WAVE PARAMETERS ---
t = 0:0.05:100; % Time array (extended duration)
f = 0.2;        % Frequency of the waves

% Wave 1: Trapezoid pattern via extreme clipping
wave1 = round(1500 * sin(2*pi*f*t)); 
wave1(wave1 > 1023) = 1023; % Flatten the top to maximum 10-bit limit
wave1(wave1 < 0) = 0;       % Flatten the bottom to 0

% Wave 2: Standard Sine pattern
wave2 = round(511.5 * sin(2*pi*f*t) + 511.5);

% --- UI SETUP ---
fig = figure('Name', 'Dual 10-bit PWM via String');
keepRunning = true;

% Create a STOP button on the graph to gracefully exit the loop
btn = uicontrol('Style', 'pushbutton', 'String', 'STOP TRANSMISSION', ...
    'Position', [20 20 150 30], ...
    'Callback', 'keepRunning = false;'); 

% Setup Subplots for visualization
subplot(1, 2, 1); hold on; title('Trapezoid (PWM 1)'); ylim([0 1100]); xlabel('Time'); ylabel('Duty Cycle');
subplot(1, 2, 2); hold on; title('Sine Wave (PWM 2)'); ylim([0 1100]); xlabel('Time'); ylabel('Duty Cycle');

% --- TRANSMISSION LOOP ---
i = 1;
while keepRunning && i <= length(t)
    
    val1 = wave1(i);
    val2 = wave2(i);
    
    % Create the formatted string WITHOUT manually adding \n at the end
    % The output will look like: "A1023B512"
    str_data = sprintf("A%dB%d", val1, val2);
    
    % writeline automatically sends the string + clean terminator (\n)
    writeline(s, str_data);
    
    % Live plotting
    subplot(1, 2, 1); plot(t(1:i), wave1(1:i), 'b-', 'LineWidth', 2);
    subplot(1, 2, 2); plot(t(1:i), wave2(1:i), 'b-', 'LineWidth', 2);
    drawnow;
    
    % Delay to match physical real-time flow
    pause(0.5); 
    i = i + 1;
end

disp('Transmission Complete or Stopped by User.');

% --- HELPER FUNCTION ---
function closeSerialPort()
    % Find all open serial ports and close them to prevent "Port in use" errors
    portList = serialportlist;
    if ~isempty(portList)
        clear s;
    end
    disp('COM Port closed safely and is ready for the next run.');
end