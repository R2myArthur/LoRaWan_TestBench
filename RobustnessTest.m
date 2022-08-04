%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Robustess tes of a LoRaWAN %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%% PRECONDITIONS %%%%%%%%%%%%%%%

%% Connection MQTT
try
    clear mqtt_client;
catch
end
mqtt_client = init_MQTT_Client("tcp://128.131.85.183", 1883);
KeepAliveDuration=minutes(24*60);

%% Connection serial port
try
    clear s_stm;
catch
end
s_stm = init_serial('COM5', 9600, "CR");

%% Show help
send_cmd(s_stm, 'AT?');
readSerialData(s_stm);

%% Reset board
send_cmd(s_stm, 'ATZ');
% readSerialData(s_stm);

%% Configure board
stm_config(s_stm, '31:31:35:38:60:37:8F:18', '01:01:01:01:01:01:01:01', '2B:7E:15:16:28:AE:D2:A6:AB:F7:15:88:09:CF:4F:3C');

%% Join Network
flush(mqtt_client);
stm_joinNetwork(s_stm);


%% Read and show data from MQTT Client
gatewayId = 'e45f01fffe1f773b';

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


%% Class C
disp("Change Equipment Class in C");
send_cmd(s_stm, 'AT+CLASS=C');


%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%
%% Send Data
% while (1)
%     send_cmd(s_stm, 'AT+SEND=1:0:ABCDEF');
% end

% %% Send down data
% % Create down message on MQTT broker
% deveui = '3131353860378f18';
% % pattern = 'q83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83vq83v';
% % pattern = 'q83v';
% % pattern = matlab.net.base64encode(0xaaaaa);
% pattern = 'qqqq';
% 
% % for  i = 0:1:100
% i=0;
% while (1)
%     clear data;
%     clear dt;
%     disp(['Boucle n' int2str(i)]);
%     i = i +1;
%     write_MQTT_message(mqtt_client, ['application/2/device/' deveui '/tx'], ['{"confirmed":false,"fPort":1,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":2,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":3,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":4,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":5,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":6,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":7,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":8,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":9,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":10,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":11,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":12,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":13,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":14,"data":"' pattern '"}']);
% %     write_MQTT_message(mqtt_client, 'application/2/device/3131353860378f18/tx', ['{"confirmed":false,"fPort":15,"data":"' pattern '"}']);
%      
%     % Get Packet from MQTT Broker and verify Data on MQTT Broker
%     data = read_MQTT_subscribe(mqtt_client, ['application/2/device/' deveui '/tx']);
%     
%     if ( count(data.Data, pattern) )
%         disp('Server received the MQTT instruction');
%         send_cmd(s_stm, 'AT+SEND=1:0:ABCDEF');
%         pause(1);
% 
%         dt = read(s_stm,s_stm.NumBytesAvailable,'string');
%         disp(dt);
%         writeDataInFile('test.txt', dt);
% %         if ( count(dt, 'aaaaaa') )
% %             disp('A download message is received');
% %         else
% %             disp("NO DOWLOAD message");
% %             disp(dt);
% %         end
%     else
%         disp("Server didn't received MQTT instructions");
%         disp(data);
%     end
%     pause(1/2);
% end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ROBUSTNESS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure the limit of robustness test
MAX_UP_FRAME = 10;          % Number of frame UP to send per loop
MAX_SIZE_FRAME_UP = 242;    % Number of Bytes (242 bytes max)
% End of configuration
MAX_FPORT = 223;            % [1..223]

disp(strcat("MAX_UP_FRAME: ", string(MAX_UP_FRAME)));
disp(strcat("MAX_SIZE_FRAME_UP: ", string(MAX_SIZE_FRAME_UP)));
disp(strcat("MAX_FPORT: ", string(MAX_FPORT)));

s_stm.UserData = "";

while (1)
    % Choose random UP or DOWN Data
    if ( randi(2) == 1 )
        % Send Data UP
        disp("Send data UP");
        % Number of UP frame to send
        number_of_frame_up = randi(MAX_UP_FRAME);
        disp(strcat(string(number_of_frame_up), " frames will be send"));
        % Loop the number of frame to send
        for i = 1:number_of_frame_up % SKIP ONLY 1
            disp(['Loop num ' int2str(i)]);

            % Size of data in frame to UP
            size_of_frame_up = randi(MAX_SIZE_FRAME_UP);
            % Generate random data in hex string (d
            payload_to_up = strjoin(string(dec2hex(randi([0 255], 1, size_of_frame_up))), '');
            
            % Random choice fport [1..223]
            fport = int2str(randi(MAX_FPORT));
            % Random choice of message type 'Confirmed' (1) or 'Unconfirmed' (0)
%             confirmation = int2str(randi(2) - 1);
            confirmation = '0';

            % Send command to the device (AT+SEND=<port>:<ack>:<payload>)
            disp(strcat('Frame to send UP: fport=', fport, ' ; Confirmed=', confirmation, ' ; Payload=', payload_to_up));

            send_cmd(s_stm, strcat('AT+SEND=', fport, ':', confirmation, ':', payload_to_up));
            
            % Wait response OK/ERROR
            is_all_data_received = false;
            is_OK_received = false;
            is_SEND_CONFIRMED_received = false;
            % #TODO Add timeout
            while (isempty(s_stm.UserData)), end

            % Look for answer
            if confirmation == '0'
                while ( is_OK_received == false )
                    pause(1/50);
                    if ( ~isempty(s_stm.UserData) )
                        if ( contains(s_stm.UserData(1), "OK") )
                            disp('Device send data to the LoRa Network OK');
                            is_OK_received = true;
                        elseif ( contains(s_stm.UserData(1), "AT_") )
                            disp(strcat('Device Error message: ', s_stm.UserData(1)));
                            break;
                        end
                        % Delete Data already read
                        s_stm.UserData(1) = [];
                    end
                end
            elseif confirmation == '1'
                while (is_OK_received == false || is_SEND_CONFIRMED_received == false )
                    pause(1/50);
                    if ( ~isempty(s_stm.UserData) )
                        if ( contains(s_stm.UserData(1), "OK") )
                            disp('Device send data to the LoRa Network OK');
                            is_OK_received = true;
                        elseif ( contains(s_stm.UserData(1), "EVT:SEND_CONFIRMED") )
                            disp('Send Data is confirmed');
                            is_SEND_CONFIRMED_received = true;
                        elseif ( contains(s_stm.UserData(1), "AT_") )
                            disp(strcat('Device Error message: ', s_stm.UserData(1)));
                            break;
                        end
                        % Delete Data already read
                        s_stm.UserData(1) = [];
                    end
                end
            end

%             while (is_all_data_received == false)
%                 if ( contains(s_stm.UserData(1), "OK") )
%                     disp('Device send data to the LoRa Network OK');
%                     is_OK_received = true;
%                 elseif ( contains(s_stm.UserData(1), "EVT:SEND_CONFIRMED") )
%                     disp('Send Data is confirmed');
%                     is_SEND_CONFIRMED_received = true;
%                 elseif ( contains(s_stm.UserData(1), "AT_") )
%                     disp(strcat('Device Error: ', s_stm.UserData(1)));
%                     is_OK_received = false;
%                     is_SEND_CONFIRMED_received = false;
%                 end
% 
%                 % Delete Data already read
%                 s_stm.UserData(1) = [];
% 
%                 % Get out if no more data
%                 if ( isempty(s_stm.UserData) )
%                     is_all_data_received = true;
%                     if ( confirmation == '1' )
%                         if ( is_OK_received == true && is_SEND_CONFIRMED_received == true )
%                             disp('Send Data and confirmation received OK');
%                         else
%                             disp('ERROR Send Data and confirmation ');
%                         end
%                     else
%                         if ( is_OK_received == true )
%                             disp('Send Data OK');
%                         else
%                             disp('ERROR Send Data');
%                         end
%                     end
%                 end
%             end
        end
    else
        disp("Send data DOWN");
    end

end
