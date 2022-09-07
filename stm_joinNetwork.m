%% Configure STM Board with LORA parameters
% Param
%   serial      : Serialport object : Connection to the port
%   gatewayId   : String            : Gateway ID to join (ex: 'e45f01fffe1f773b')
%   mqtt_client : Client object     : MQTT client connected to a MQTT broker
%
% Return Nothing

function res = stm_joinNetwork (serial, gatewayId, mqtt_client)
    writeToScreenAndFile("Send the Join Network CMD");
    
    % Flush MQTT Buffer
    flush(mqtt_client);

    % Send the Join CMD in OTAA mode
    send_cmd(serial, 'AT+JOIN=1');
    
    res = false;
    while ( 1 )
        data_received = readline(serial);
        writeToScreenAndFile(sprintf("Received data: %s", data_received));

        % Processing the received data
        if ( ~isempty(data_received) )
            % Error on the device (busy, wrong parameter...)
            if ( contains(data_received, "AT_"))
                writeToScreenAndFile("ERROR: Serial error");
                break;
            % Network successfull joined
            elseif ( contains(data_received, "EVT:JOINED") )
                res = true;
                writeToScreenAndFile("LoRa Network is successfully joined");
                break;
            % Impossible to joined the Network
            elseif ( contains(data_received, "EVT:JOIN FAILED") )
                writeToScreenAndFile("ERROR: Impossible to join the LoRa server");
                break;
            end
        end
    end

    % Read and show data from MQTT Client
    if ( res == true )
        try
            clear data_up_str;
            clear data_down_str;
            data_up_str   = read_MQTT_subscribe(mqtt_client, ['gateway/' gatewayId '/event/up']);
            data_down_str = read_MQTT_subscribe(mqtt_client, ['gateway/' gatewayId '/command/down']);
        catch
        end
        
        % Decode JSON Data
        if ( exist("data_down_str","var") && exist("data_up_str","var") && not(isempty(data_down_str)) && not(isempty(data_up_str)) )
            disp("The Device join the chirpstack server")
            data_up_json = jsondecode(data_up_str.Data);
            disp(data_up_json);
            data_down_json = jsondecode(data_down_str.Data);
            disp(data_down_json);
        else
            disp("No result on the chirpstack server");
        end
    end
    % Clean the serial buffer before to leave
    serial.flush();
    % Time for the network
    pause(3);
end