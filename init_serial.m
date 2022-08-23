function serial = init_serial(port, speed, terminator)
    disp(['Connection of device ' port]);

    % Create the serial port
    serial = serialport(port, speed);

    % Change the character of end of line
    configureTerminator(serial, terminator);

    % Change the reception timeout
%     serial.Timeout = 7; % Use for test, not use in this case
    
    % Configure a callback on readserial, not use in this case
%     configureCallback(serial,"terminator",@receivedSerialData)
end