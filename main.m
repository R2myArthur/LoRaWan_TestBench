%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Main File of Test Bench LoRaWAN %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Connection MQTT
try
    clear mqtt_client;
catch
end
mqtt_client = init_MQTT_Client("tcp://128.131.85.238", 1883);
KeepAliveDuration=minutes(24*60);


%%% RN2483

%% Connection serial port
try
    clear s;
catch
end
s = init_serial('COM6', 57600, "CR/LF");

%% Config End Device
deviceEUI = 'a2ef0680c6610dfc';
rn2483_config(s, '868', 'a2ef0680c6610dfc', '0000000000000000', 'd6070b81c623f5fd6e6779be634aef86', 'a')

%% Join LoRaWan Network
send_cmd(s, 'mac join otaa');
readSerialData(s);
readSerialData(s);

%% Read and show data from MQTT Client
gatewayId = 'b827ebfffef6d838';
data_up_str   = read_MQTT_subscribe(mqtt_client, ['gateway/' gatewayId '/event/up']);
data_down_str = read_MQTT_subscribe(mqtt_client, ['gateway/' gatewayId '/command/down']);

%% Decode JSON Data
data_up_json = jsondecode(data_up_str.Data);
disp(data_up_json);
data_down_json = jsondecode(data_down_str.Data);
disp(data_down_json);


%% Send Data From end device to Gateway
rn2483_sendData(s, 'cnf', '1', 'aaaaaa');
readSerialData(s);
readSerialData(s);


%% Read and show data from MQTT Client
Application_number = 2;
% data_up_str   = read_MQTT_subscribe(mqtt_client, ['application/' Application_number '/device/' deviceEUI '/rx']);
data_app = read_MQTT_subscribe(mqtt_client, 'application/2/device/a2ef0680c6610dfc/rx');

data_app = jsondecode(data_app.Data(1));
