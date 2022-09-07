%% Connects to the serial port specified by port and configure it
% Param
%   port : string : Serial : port for connection (ex: "COM1")
%   speed         : int    : Communication speed in bits per second (baudrate) (ex: 9600)
%   terminator    : string : Terminator character for reading and writing
%   ASCII-terminated data (ex: "CR/LF")
%
% Return an object Serialport

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