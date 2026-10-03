clc;
clear;
baud_rate = 9600;
s = serialport("COM2", baud_rate);

disp('Reading data from STM32... (Press Ctrl+C to stop)');

while true
    data = read(s, 2, "uint8");

    if length(data) == 2
        adc_raw = bitshift(data(1), 8) + data(2);

        voltage = (adc_raw * 3.3) / 4095.0;

        fprintf('Raw ADC: %04d | Voltage: %.2f V\n', adc_raw, voltage);
    end
    
    pause(0.05); 
end