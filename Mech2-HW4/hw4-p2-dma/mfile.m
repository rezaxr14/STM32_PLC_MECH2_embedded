clear; clc;

serialPortName = 'COM2';
baudRate = 9600;              
timeoutSeconds = 5;           

availablePorts = serialportlist("available");
if ~ismember(serialPortName, availablePorts)
    error('Port %s not found. Check virtual COM port or Proteus COMPIM settings.', serialPortName);
end

oldPort = serialportfind("Port", serialPortName);
if ~isempty(oldPort)
    delete(oldPort);
    fprintf('Closed existing connection on %s.\n', serialPortName);
end

fprintf('Connecting to %s at %d baud ...\n', serialPortName, baudRate);
try
    stm32 = serialport(serialPortName, baudRate);
    stm32.Timeout = timeoutSeconds;
    fprintf('Connected successfully.\n\n');
catch ME
    error('Connection failed: %s\nCheck: Port number, cable, COMPIM settings, no other app using it.', ME.message);
end

fprintf('Enter an integer between 0 and 240. Type "exit" to quit.\n');
while true
    userInput = input('Your number (0-240): ', 's');
    if strcmpi(userInput, 'exit')
        break;
    end
    
    number = str2double(userInput);
    if isnan(number) || number < 0 || number > 240 || mod(number,1) ~= 0
        fprintf('Invalid input. Please enter an integer from 0 to 240.\n');
        continue;
    end
    
    dataToSend = uint8(number);
    try
        write(stm32, dataToSend, "uint8");
        fprintf('Sent: %d (0x%s)\n', number, dec2hex(dataToSend));
    catch ME
        fprintf('Send error: %s\n', ME.message);
        break;
    end
    
    try
        received = read(stm32, 1, "uint8");
        fprintf('Received: %d (0x%s)  →  Expected: %d\n', ...
                received, dec2hex(received), number + 10);
    catch ME
        if contains(ME.message, 'timeout')
            fprintf('Timeout: No response from STM32.\n');
            fprintf('Check: Is the STM32 firmware running? TX/RX wired correctly?\n');
        else
            fprintf('Receive error: %s\n', ME.message);
        end
        break;
    end
    fprintf('---\n');
end

clear stm32;
fprintf('\nSerial port closed. Done.\n');