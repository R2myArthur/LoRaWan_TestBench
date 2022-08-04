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
    clear s_rn2483;
catch
end
s_rn2483 = init_serial('COM6', 57600, "CR/LF");


%% Reset board
rn2483_config(s_rn2483, '868', 'a2ef0680c6610dfc', '0000000000000000', 'd6070b81c623f5fd6e6779be634aef86')

%% Join network
rn2483_joinNetwork(s_rn2483);

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
    disp("No result on the chirpstack server")
end

%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%
%% Send Data up
send_cmd(s_rn2483, 'mac tx uncnf 4 AAAAAA');
pause(5);
dt = readSerialData(s_rn2483);
disp(dt);
if ( contains(dt, 'OK') )
    disp('Message transmit');
else
    disp(["Message error: " dt]);
end

%% Send down data
% Create down message on MQTT broker
deveui = 'a2ef0680c6610dfc';
pattern = matlab.net.base64encode(0xaaaaaaaaaaaaaaaa);

for  i = 0:1:100
    clear data;
    clear dt;
    disp(['Boucle n' int2str(i)]);

    write_MQTT_message(mqtt_client, ['application/2/device/' deveui '/tx'], ['{"confirmed":false,"fPort":1,"data":"' pattern '"}']);
 
    % Get Packet from MQTT Broker and verify Data on MQTT Broker
    data = read_MQTT_subscribe(mqtt_client, ['application/2/device/' deveui '/tx']);
    
    if ( count(data.Data, pattern) )
        disp('Server received the MQTT instruction');
    else
        disp("Server didn't received MQTT instruction s");
        disp(data);
    end
    pause(1/2);
end

%%%%%%%%%%%%%%% POSTCONDITIONS %%%%%%%%%%%%%%%


