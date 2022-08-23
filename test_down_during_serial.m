
DEVEUI = '3131353860378f18';
fport = 2;
payload_to_down = 'dQ==';
% pause(10);
while (1)
    write_MQTT_message(mqtt_client, ['application/2/device/' DEVEUI '/tx'], ['{"confirmed":false,"fPort":' int2str(fport) ',"data":"' payload_to_down '"}']);
    
%     send_cmd(s_stm, 'AT?');
    
    while (1)
        rsp = readline(s_stm);
%         if ( isempty(rsp) )
        fprintf('%s\n', rsp);
        if ( contains(rsp, 'RX_C on freq') )
            break;
        end
    end
    pause(2);
end