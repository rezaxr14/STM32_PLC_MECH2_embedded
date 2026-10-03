clear; clc;

baud_rate = 9600;
stm32_port = serialport("COM2", baud_rate);

pause(1);

disp('Starting transmission to STM32 (DMA Padded)...');
disp('---------------------------------');

my_name = "Reza Nadimi";

for count = 1:10
    
    % '%-19s' means: Treat my_name as a string, left-justify it, 
    % and pad it with blank spaces until it is exactly 19 characters long.
    % The '\n' adds the 20th character!
    text_to_send = sprintf('%-19s\n', my_name);
    
    write(stm32_port, text_to_send, "string");
    
    fprintf('Sent %d/10: [%s]\n', count, strtrim(text_to_send));
    
    pause(2.5); 
    
end

disp('---------------------------------');
disp('All 10 messages sent successfully!');