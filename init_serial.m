function serial = init_serial(port, speed, terminator)
    serial = serialport(port, speed);
    configureTerminator(serial, terminator);
    % Configure a callback on readserial
    configureCallback(serial,"terminator",@readSerialData)
end