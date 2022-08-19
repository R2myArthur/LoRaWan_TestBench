function res = stm_joinNetwork (serial)
    writeToScreenAndFile("Send the Join Network CMD");
    res = false;

    send_cmd(serial, 'AT+JOIN=1');

    data_received = "";
    while( ~contains(data_received, "OK") && ~contains(data_received, "AT_")  )
        data_received = readline(serial);
        writeToScreenAndFile(sprintf("Serial received: %s", data_received));
    end

    if ( contains(data_received, "OK") )
        while ( 1 )
            data_received = readline(serial);
            writeToScreenAndFile(sprintf("Received data: %s", data_received));
            if ( ~isempty(data_received) )
                if ( contains(data_received, "EVT:JOINED") )
                    res = true;
                    writeToScreenAndFile("LoRa Network is successfully joined");
                    break;
                elseif ( contains(data_received, "EVT:JOIN FAILED") )
                    writeToScreenAndFile("ERROR: Impossible to join the LoRa server");
                    break;
                end
            end
        end
        serial.flush();
    elseif ( contains(data_received, "AT_") )
        writeToScreenAndFile("ERROR: Impossible to LoRa communication");
    else
        writeToScreenAndFile("ERROR: Join error");
    end
end