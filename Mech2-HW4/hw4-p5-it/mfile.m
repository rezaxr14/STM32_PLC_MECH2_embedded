clear; clc;

baud_rate = 9600;
stm32_port = serialport("COM2", baud_rate);
configureTerminator(stm32_port, "LF");

stm32_port.Timeout = 30; 

disp('Waiting for data from the microcontroller...');
disp('Press the RESET button on your STM32 board now!');
disp('----------------------------------------------------');

flush(stm32_port); 

for count = 1:10
    received_text = readline(stm32_port);
    fprintf('Message %d: %s\n', count, received_text);
end

disp('----------------------------------------------------');
disp('Successfully received all 10 messages.');