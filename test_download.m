
deveui = '3131353860378f18';
pattern = 'qqqq';
i = 0;
% for  i = 0:1:100
while (1)
    clear data;
    clear dt;
    disp(['Boucle n' int2str(i)]);
    i = i + 1;

    write_MQTT_message(mqtt_client, ['application/2/device/' deveui '/tx'], ['{"confirmed":false,"fPort":1,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":2,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":3,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":4,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":5,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":6,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":7,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":8,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":9,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":10,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":11,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":12,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":13,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":14,"data":"' pattern '"}']);
%     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":15,"data":"' pattern '"}']);
     
    % Get Packet from MQTT Broker and verify Data on MQTT Broker
    data = read_MQTT_subscribe(mqtt_client, ['application/2/device/' deveui '/tx']);
    
    if ( count(data.Data, pattern) )
        disp('Server received the MQTT instruction');

        pause(4);
%         dt = waitSerialData(s_stm);
        dt = read(s_stm,s_stm.NumBytesAvailable,'string');
        disp(dt);
        if ( count(dt, 'aaaaaa') )
            disp('A download message is received');
        else
            disp("NO DOWLOAD message");
            disp(dt);
        end
    else
        disp("Server didn't received MQTT instructions");
        disp(data);
    end
    pause(1/2);
end

