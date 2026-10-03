clc;
clear;

baud_rate = 9600; 
s = serialport("COM2", baud_rate);
configureTerminator(s, "CR/LF");

disp('Reading raw data and calculating voltages... (Press Ctrl+C to stop)');

while true
    try
        % Read the incoming text line from the STM32
        str_data = readline(s);
        
        if strlength(str_data) > 0
            % Read the numbers out of the string using sscanf
            % This looks for the exact text format we set in the C code
            parsed_data = sscanf(str_data, "Channel 1: %d | Channel 2: %d | Channel 3: %d");
            
            % If it successfully found all 3 numbers, do the math
            if length(parsed_data) == 3
                raw_ch1 = parsed_data(1);
                raw_ch2 = parsed_data(2);
                raw_ch3 = parsed_data(3);
                
                % Convert digital numbers to voltages
                v1 = (raw_ch1 * 3.3) / 4095.0;
                v2 = (raw_ch2 * 3.3) / 4095.0;
                v3 = (raw_ch3 * 3.3) / 4095.0;
                
                % Display the final output with both the raw number and the voltage
                fprintf('CH1: %04d -> %.2f V | CH2: %04d -> %.2f V | CH3: %04d -> %.2f V\n', ...
                        raw_ch1, v1, raw_ch2, v2, raw_ch3, v3);
            else
                % Fallback: If the string doesn't match the format exactly, just print what arrived
                disp(str_data);
            end
        end
        
    catch
        disp('Error reading from serial port or operation stopped.');
        break;
    end
end