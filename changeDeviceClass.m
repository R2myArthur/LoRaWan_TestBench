% Change device classe
% Param:
%   serial : Serialport object : Connection to the port
%   string classe : 'A' or 'C'
%
% Return nothing

function changeDeviceClass(serial, classe)
    writeToScreenAndFile(sprintf("Change Equipment Class in %s", classe));

    % Send the serial CMD to the device
    send_cmd(serial, ['AT+CLASS=' classe]);

    % Read Data on the Port COM
    while( 1 )
        rep = readline(serial);
%          writeToScreenAndFile(rep); % Debug
        if ( ~isempty(rep) )


            if ( contains(rep, 'OK') )
                writeToScreenAndFile("Change Equipment Class OK");
                break;
            elseif ( contains(rep, "AT_") )
                writeToScreenAndFile(sprintf("ERROR: Device return an error: %s", rep));
                break;
            end
        else
            writeToScreenAndFile("ERROR: Unexpected, no serial data received");
        end
    end
end