% Set up the serial port (Update 'COM3' to match your virtual port setup)
try
    clear s; % Clear the port if it was left open from a previous run
catch
end
s = serialport("COM3", 9600);

disp('--- Starting Raw Binary Hardware Test Sequence ---');

% ---------------------------------------------------------
% Step 0: Initialize safely at 50 Hz, 50% Duty Cycle
% ---------------------------------------------------------
disp('Initializing to 50 Hz, 50% Duty Cycle...');
% Send Freq = 50 (Command 1)
write(s, [bitor(bitshift(1, 4), bitshift(50, -8)), bitand(50, 255)], "uint8");
% Send Duty = 2048 (Command 2)
write(s, [bitor(bitshift(2, 4), bitshift(2048, -8)), bitand(2048, 255)], "uint8");
pause(3); % Hold for 3 seconds so you can see the baseline


% ---------------------------------------------------------
% Step 1: Slowly sweep Frequency up to 1000 Hz
% ---------------------------------------------------------
disp('Slowly Sweeping Frequency Up...');
% Taking steps of 25 Hz to make it extremely smooth
for freq = 50:25:1000
    write(s, [bitor(bitshift(1, 4), bitshift(freq, -8)), bitand(freq, 255)], "uint8");
    fprintf('Frequency: %d Hz\n', freq);
    pause(0.4); % Wait almost half a second per step
end

disp('Holding at 1000 Hz...');
pause(3);


% ---------------------------------------------------------
% Step 2: Sweep Duty Cycle down to 5%, then up to 95%
% ---------------------------------------------------------
disp('Slowly Sweeping Duty Cycle Down...');
% Drops from ~50% down to ~5%
for duty = 2048:-80:200
    write(s, [bitor(bitshift(2, 4), bitshift(duty, -8)), bitand(duty, 255)], "uint8");
    fprintf('Duty Cycle: %d / 4095\n', duty);
    pause(0.3);
end

pause(2); % Brief hold at the bottom

disp('Slowly Sweeping Duty Cycle Up...');
% Rises from ~5% up to ~95%
for duty = 200:80:3800
    write(s, [bitor(bitshift(2, 4), bitshift(duty, -8)), bitand(duty, 255)], "uint8");
    fprintf('Duty Cycle: %d / 4095\n', duty);
    pause(0.3);
end

disp('Holding Duty Cycle...');
pause(3);


% ---------------------------------------------------------
% Step 3: Safely return to baseline so the wave doesn't disappear
% ---------------------------------------------------------
disp('Returning to stable baseline (50 Hz, 50%)...');
write(s, [bitor(bitshift(1, 4), bitshift(50, -8)), bitand(50, 255)], "uint8");
write(s, [bitor(bitshift(2, 4), bitshift(2048, -8)), bitand(2048, 255)], "uint8");

disp('--- Test Sequence Complete ---');