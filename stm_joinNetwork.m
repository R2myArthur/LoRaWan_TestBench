function res = stm_joinNetwork (serial)
    res = false;
    send_cmd(serial, 'AT+JOIN=1');
    pause(8);
    data = readSerialData(serial);
    for n=1 : length(data)
        disp(data(n));
        if ( contains(data(n), "EVT:JOINED") )
            res = true;
            disp("Connected to the gateway");
            break;
        end
    end
end