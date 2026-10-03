clear; clc;

baud_rate = 9600; 
stm32_port = serialport("COM2", baud_rate);

disp('Starting transmission. Press Ctrl+C to stop.');

while true
    
    for val = 0:255
        write(stm32_port, val, "uint8"); 
        pause(0.1); 
    end
    %{ 
 
    //for making triangle shape we can add this to the code!
    for val = 254:-1:1
        write(stm32_port, val, "uint8");
        pause(0.1); 
    end
    %}
end
