clear; clc;

baud_rate = 9600;
stm32_port = serialport("COM2", baud_rate);

pause(1);

disp('Starting transmission to STM32...');
disp('---------------------------------');

my_name = "Reza Nadimi";

for count = 1:10
    
    text_to_send = sprintf('%s\n', my_name);
    
    write(stm32_port, text_to_send, "string");
    
    fprintf('Sent %d/10: %s\n', count, my_name);
    
    pause(2.5);
    
end

disp('---------------------------------');
disp('All 10 messages sent successfully!');