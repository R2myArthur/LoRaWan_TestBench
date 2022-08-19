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

%% Connection serial port
try
    clear s_stm;
catch
end
s_stm = init_serial('COM5', 9600, "CR/LF");

%% Reset board and Show help

% Reset STM Board
send_cmd(s_stm, 'ATZ');
data_to_read = false;
while( data_to_read == false  )
    data_received = readline(s_stm);
    if ( isempty(data_received) )
        data_to_read = true;
    else
        writeToScreenAndFile(data_received);
    end
end

% Show help
send_cmd(s_stm, 'AT?');
data_to_read = false;
while( data_to_read == false )
    data_received = readline(s_stm);
    if ( isempty(data_received) )
        data_to_read = true;
    else
        writeToScreenAndFile(data_received);
    end
end

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

%% UP test for Debug
% flush(s_stm);
% 
% % fport = 66;
% % confirmation =0
% % payload_to_up = "F261B19AC69760D939CCFF48B5AA6A7FF2F4BB620A95905AE19F9F4B13"
% 
% while 1
%     send_cmd(s_stm, strcat('AT+SEND=', int2str(fport), ':', confirmation, ':', payload_to_up));
% 
%     c = 0;
%     while c < 11
%         rsp = readline(s_stm);
%         fprintf('%s\n', rsp);
%         if isequal(rsp, 'AT_BUSY_ERROR')
%             flush(s_stm);
%             break;
%         end
% %         if isempty(rsp)
% %             pause(2);
% %             flush(s_stm);
% %         end
%         if ~isempty(rsp) && rsp(1)=='+'
%         else
%             c = c + 1;
%         end
%     end
% 
%     if s_stm.NumBytesAvailable
%         error('buffer not empty');
%     end
% 
% %     pause(4);
% end

%%
%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ROBUSTNESS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure the limit of robustness test
MAX_SIZE_FRAME_UP = 40;     % Number of Bytes (242 bytes max)
MAX_SIZE_FRAME_DOWN = 51;   % Size of data to send DOWN (51 bytes max)
MAX_FPORT = 223;            % Number of LoRa port to use [1..223]
DEVEUI = '3131353860378f18';% End device identifier
% End of configuration

writeToScreenAndFile(strcat("MAX_SIZE_FRAME_UP: ", string(MAX_SIZE_FRAME_UP)));
writeToScreenAndFile(strcat("MAX_SIZE_FRAME_DOWN: ", string(MAX_SIZE_FRAME_DOWN)));
writeToScreenAndFile(strcat("DEVEUI: ", DEVEUI));
writeToScreenAndFile(strcat("MAX_FPORT: ", string(MAX_FPORT)));

while (1)
    % Init loop
    flush(mqtt_client);
    s_stm.flush();

    writeToScreenAndFile("**************************************");
    writeToScreenAndFile("**************************************");
    % Choose random UP or DOWN Data
    if ( randi(2) == 1 )
%     if ( 1 )          % Debug
%     if ( 0 )          % Debug
        % Send Data UP
        writeToScreenAndFile("Send data UP");
        % Size of data in frame to UP
        size_of_data = randi(MAX_SIZE_FRAME_UP);
        % Generate random data in hex string
        payload_to_up = strjoin(string(dec2hex(randi([0 255], 1, size_of_data))), '');
        
        % Random choice fport [1..223]
        fport = randi(MAX_FPORT);
        % Only use Unconfirmed message (0)
        confirmation = '0';

        % Send command to the device (AT+SEND=<port>:<ack>:<payload>)
        writeToScreenAndFile(strcat('Frame to send UP: fport=', int2str(fport), ' ; Payload=', payload_to_up));
        send_cmd(s_stm, strcat('AT+SEND=', int2str(fport), ':', confirmation, ':', payload_to_up));
        
        % Wait response OK/ERROR
        data_received = readline(s_stm);
        while( ~contains(data_received, "OK") && ~contains(data_received, "AT_")  )
            data_received = readline(s_stm);
            writeToScreenAndFile(sprintf("Serial confirmation received: %s", data_received));
        end

        is_end = false;
        while( is_end == false )
            data_received = readline(s_stm);
            if ( isempty(data_received) )
                is_end = true;
            else
                writeToScreenAndFile(sprintf("Serial confirmation received: %s", data_received));
            end
        end
        
        try
            % Read MQTT data
            MQTT_data = read_MQTT_subscribe(mqtt_client, ['application/2/device/' DEVEUI '/rx']);
            % Data processing only if something is received
            if ( ~isempty(MQTT_data) )
                % Decode received data in a JSON format
                MQTT_data_json = jsondecode(MQTT_data.Data);
                % Verify fport, deveui and data are what we sent
                if ( MQTT_data_json.fPort == fport && MQTT_data_json.devEUI == string(DEVEUI) )
                    writeToScreenAndFile(sprintf("MQTT Data received: %s", MQTT_data_json.data));
                    writeToScreenAndFile("Transmission OK");
                else
                    writeToScreenAndFile("ERROR Transmission MQTT");
                end
            else
                writeToScreenAndFile("ERROR Transmission Serial");
            end
        catch e % e is an MException struct
            writeToScreenAndFile(sprintf('The identifier was: %s',e.identifier));
            writeToScreenAndFile(sprintf('There was an error! The message was: %s',e.message));
        end
    else
        writeToScreenAndFile("Send data DOWN");
        % Size of data in frame to DOWN
        size_of_data = randi(MAX_SIZE_FRAME_DOWN);
        % Generate random data in hex string
        random_data = randi([0x0 0xFF], 1, size_of_data, 'uint8');
        payload_to_up = matlab.net.base64encode(random_data);
%         payload_to_up = matlab.net.base64encode(0xaaaaaaaaaaaaaaaa);          % Debug
        
        % Random choice fport [1..223]
        fport = randi(MAX_FPORT);
        
        % Send MQTT message for DOWN Frame
        writeToScreenAndFile(sprintf('MQTT Topic: "application/2/device/%s/tx"', DEVEUI));
        writeToScreenAndFile(sprintf('MQTT Message: {"confirmed":false,"fPort":%d,"data":"%s"}', fport, payload_to_up));
        write_MQTT_message(mqtt_client, ['application/2/device/' DEVEUI '/tx'], ['{"confirmed":false,"fPort":' int2str(fport) ',"data":"' payload_to_up '"}']);
        try
            % Verify message is received by the STM device with the right data
            data_received_down = "";
            check_data = lower(strjoin(string(dec2hex(random_data)), ''));
            size_of_check_data = string(dec2hex(strlength(check_data) / 2, 2));
            while( ~contains(data_received_down, strcat("EVT:", int2str(fport), ":", size_of_check_data, ":", check_data )) )
                data_received_down = readline(s_stm);
                writeToScreenAndFile(sprintf("Serial data Received: %s", data_received_down));
            end            
        catch e %e is an MException struct
            writeToScreenAndFile(sprintf('The identifier was: %s', e.identifier));
            writeToScreenAndFile(sprintf('There was an error! The message was: %s', e.message));
            pause(20);
            if ( s_stm.NumBytesAvailable > 1 )
                data_received_down = read(s_stm,s_stm.NumBytesAvailable,'string');
                writeToScreenAndFile(sprintf('Data received after TimeOut: %s', data_received_down));
            else
                writeToScreenAndFile('NO data received after timeout');
            end
        end
        
        % Verify if data is received
        if ( ~isempty(data_received_down) )
%             writeToScreenAndFile(data_received_down);
%             data_received_down = readline(s_stm);
            writeToScreenAndFile("DOWN: Transmission OK");
        else
            writeToScreenAndFile("DOWN ERROR Transmission");
        end
    end
end
