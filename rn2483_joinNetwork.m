function res = rn2483_joinNetwork(serial)
    res = false;
    send_cmd(serial, 'mac join otaa');
    pause(8);
    data = readSerialData(serial);
    if ( contains(data(1), "ok") )
        if ( contains(data(2), "joined") )
            res = true;
            disp("Connected to the gateway");
        end
    end
end