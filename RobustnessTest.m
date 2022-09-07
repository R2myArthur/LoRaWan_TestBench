%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Robustess tes of a LoRaWAN %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Global parameters
% MANUALLY CONFIGURATION
MQTT_BROKER_ADDRESS = "tcp://128.131.85.183";
MQTT_BROKER_PORT = 1883;

PORT_COM_NUM = 'COM5';
PORT_COM_SPEED = 9600;
PORT_COM_TERMINATOR = "CR/LF";

GATEWAYID = 'e45f01fffe1f773b';

DEVEUI = '31:31:35:38:60:37:8F:18';
APPEUI = '01:01:01:01:01:01:01:01';
APPKEY = '2B:7E:15:16:28:AE:D2:A6:AB:F7:15:88:09:CF:4F:3C';

DEVICE_CLASS = 'C';

% Configure the limit of robustness test
MAX_SIZE_FRAME_UP = 40;     % Number of Bytes (242 bytes max)
MAX_SIZE_FRAME_DOWN = 51;   % Size of data to send DOWN (51 bytes max)
MAX_FPORT = 223;            % Number of LoRa port to use [1..223]
DEVEUI_HEX = '3131353860378f18'; % Letters should be in minus (ex: "ab12cd")
% End of configuration

%%%%%%%%%%%%%%% PRECONDITIONS %%%%%%%%%%%%%%%
%% Connection MQTT
try
    clear mqtt_client;
catch
end
mqtt_client = init_MQTT_Client(MQTT_BROKER_ADDRESS, MQTT_BROKER_PORT);

%% Connection serial port
try
    clear s_stm;
catch
end
s_stm = init_serial(PORT_COM_NUM, PORT_COM_SPEED, PORT_COM_TERMINATOR);

%% Reset board and Show help

% Reset STM Board
writeToScreenAndFile("**************************************");
send_cmd(s_stm, 'ATZ');
while( 1 )
    data_received = readline(s_stm);
    writeToScreenAndFile(data_received);
    if ( contains(data_received, "AT? to list all available functions") )
        break;
    end
end

% Show help
writeToScreenAndFile("**************************************");
send_cmd(s_stm, 'AT?');
while( 1 )
    data_received = readline(s_stm);
    writeToScreenAndFile(data_received);
    if ( contains(data_received, "OK") )
        break;
    end
end

%% Configure board
writeToScreenAndFile("**************************************");
stm_config(s_stm, DEVEUI, APPEUI, APPKEY);

%% Join Network
writeToScreenAndFile("**************************************");
stm_joinNetwork(s_stm, GATEWAYID, mqtt_client);

%% Class C
writeToScreenAndFile("**************************************");
changeDeviceClass(s_stm, DEVICE_CLASS);

%% Init radio communication with Uplink data

writeToScreenAndFile("**************************************");
end_of_up = false;
count_timeout = 0;
% Loop until a UPLINK frame is send without DOWNLINK received
while ( end_of_up == false )
    send_cmd(s_stm, 'AT+SEND=1:0:AA'); % Fport:1 ; Unconfirmed message ; random hex data
    while ( 1 )
        % Check data received and log it
        data_received = readline(s_stm);
        writeToScreenAndFile(sprintf("Serial data Received: %s", data_received));
        
        % Data is empty if an timeout occurs on serial Rx
        if ( ~isempty(data_received) )
            % received qn error from the device
            if ( contains(data_received, "AT_") )
                % To enter in the error management
                writeToScreenAndFile("ERROR: Device return an error");
                break;
            % RxDone if the transmission is finished
            elseif ( contains(data_received, "MAC rxDone") )
                % Read the two last lines received
                readline(s_stm);
                readline(s_stm);
                break;
            % Rxtimeout received two times indicates the end of transmission
            elseif ( count_timeout == 2 )
                % Read the last line received
                end_of_up = true;
                break;
            % There is two Rx timeout for an end of transmission (Rx1 and Rx2)
            elseif ( contains(data_received, "MAC rxTimeOut") )
                count_timeout = count_timeout + 1;
            end
        else
            % Nothing received from the device Port COM may be lost
            writeToScreenAndFile(sprintf("ERROR: No response from the device after timeout of %d. verify the COM port.", s_stm.Timeout));
            break;
        end
    end
end
pause(1);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send random frame DOWN or UP and verify data on serial and on MQTT     %
% server                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

writeToScreenAndFile("**************************************");
writeToScreenAndFile("Beginning of the TEST");
writeToScreenAndFile(strcat("MAX_SIZE_FRAME_UP: ", string(MAX_SIZE_FRAME_UP)));
writeToScreenAndFile(strcat("MAX_SIZE_FRAME_DOWN: ", string(MAX_SIZE_FRAME_DOWN)));
writeToScreenAndFile(strcat("DEVEUI: ", DEVEUI_HEX));
writeToScreenAndFile(strcat("MAX_FPORT: ", string(MAX_FPORT)));

while (1)
    % Flush the reception Buffer of MQTT data
    flush(mqtt_client);

    writeToScreenAndFile("**************************************");
    % Choose random UPLINK or DOWNLINK frame
%     if ( randi(2) == 1 ) % RANDOMLY DOWN OR UP
    if ( 1 )          % Debug ONLY UP
%     if ( 0 )          % Debug ONLY DOWN
        % Send UPLINK Frame
        writeToScreenAndFile("Send data UP");
        % Size of data in frame to UP
        size_of_data = randi(MAX_SIZE_FRAME_UP);
        % Generate random data (data is bytes in hex string)
        payload_to_up = strjoin(string(dec2hex(randi([0 255], 1, size_of_data))), '');
        
        % Random choice fport [1..223]
        fport = randi(MAX_FPORT);

        % Only use Unconfirmed message (0)
%         confirmation = string(randi(2) - 1); % Confirmed message is not notworking
        confirmation = '0';

        % Check if there is data in serial Buffer
        if ( s_stm.NumBytesAvailable > 1 )
            writeToScreenAndFile("WARNING: Unexpected data received");
            % Received data while buffer is not empty
            while ( 1 )
                data_received_down = readline(s_stm);
                writeToScreenAndFile(sprintf("Unexpected serial data Received: %s", data_received_down));
                % 'Empty' means that a timeout occurs on the serial reception
                if ( isempty(data_received_down) )
                    % Trace all the last MQTT subscribe. Peek read the last data of a topic but don't delete data read
                    writeToScreenAndFile(peek(mqtt_client));
                    break;
                end
            end
        end
        
        % Send command to the device (AT+SEND=<port>:<ack>:<payload>)
        writeToScreenAndFile(strcat('Frame to send UP: fport=', int2str(fport), ' ; Payload=', payload_to_up));
        send_cmd(s_stm, strcat('AT+SEND=', int2str(fport), ':', confirmation, ':', payload_to_up));
        
        % init counter for timeout Rx
        count_timeout = 0;
        is_error = false;
        while ( 1 )
            % Check data received and log it
            data_received = readline(s_stm);
            writeToScreenAndFile(sprintf("Serial data Received: %s", data_received));
            
            % Data is empty if an timeout occurs on serial Rx
            if ( ~isempty(data_received) )
                % received qn error from the device
                if ( contains(data_received, "AT_") )
                    % To enter in the error management
                    is_error = true;
                    writeToScreenAndFile("ERROR: Device return an error");
                    break;
                % RxDone or Rxtimeout are the two case to know if the transmission is finished
                elseif ( contains(data_received, "MAC rxDone") || (count_timeout == 2) )
                    writeToScreenAndFile("OK: UPLINK frame sent");
                    break;
                % There is two Rx timeout for an end of transmission (Rx1 and Rx2)
                elseif ( contains(data_received, "MAC rxTimeOut") )
                    count_timeout = count_timeout + 1;
                end
            else
                % Nothing received from the device Port COM may be lost
                writeToScreenAndFile(sprintf("ERROR: No response from the device after timeout of %d. verify the COM port.", s_stm.Timeout));
                % To enter in the error management
                is_error = true;
                break;
            end
        end
        
        if ( is_error == false )
            % Read MQTT data
            MQTT_data = read_MQTT_subscribe(mqtt_client, ['application/2/device/' DEVEUI_HEX '/rx']);
            % Data processing only if something is received
            if ( ~isempty(MQTT_data) )
                if ( height(MQTT_data) > 1 )
                    % Too much data received on the MQTT server
                    writeToScreenAndFile("ERROR: More than one frame received on the MQTT server. Verify if there is enough attenuation between device and Gateway.");
                else
                    % Decode received data in a JSON format
                    MQTT_data_json = jsondecode(MQTT_data.Data);
                    % Verify fport, deveui and data are correct
                    if ( (MQTT_data_json.fPort == fport) && (MQTT_data_json.devEUI == string(DEVEUI_HEX)) ...
                            && (strjoin(string(dec2hex(matlab.net.base64decode(MQTT_data_json.data), 2)), '') == payload_to_up) )
                        writeToScreenAndFile("Transmission OK");
                    else
                        writeToScreenAndFile("ERROR: Error in data received on the MQTT server");
                        writeToScreenAndFile(MQTT_data);
                    end
                end
            else
                writeToScreenAndFile("ERROR: No data received by the MQTT server");
            end
        end
    else
        % Send DOWNLINK Frame
        % ATTENTION: The first times after reset device, you should send
        % some UPLINK frame to exchange some packet before sending DOWNLINK frame
        writeToScreenAndFile("Send data DOWN");

        % Size of data in frame to DOWN
        size_of_data = randi(MAX_SIZE_FRAME_DOWN);
        % Generate random data in hex string
        random_data = randi([0x0 0xFF], 1, size_of_data, 'uint8');
        payload_to_down = matlab.net.base64encode(random_data);
%         payload_to_down = matlab.net.base64encode(0xaaaaaaaaaaaaaaaa);   % Debug
        
        % Random choice fport [1..223]
        fport = randi(MAX_FPORT);
                
        % Check if there is data in serial Buffer
        if ( s_stm.NumBytesAvailable > 1 )
            writeToScreenAndFile("WARNING: Unexpected data received");
            % Received data while buffer is not empty
            while ( 1 )
                data_received_down = readline(s_stm);
                writeToScreenAndFile(sprintf("Unexpected serial data Received: %s", data_received_down));
                % 'Empty' means that a timeout occurs on the serial reception
                if ( isempty(data_received_down) )
                    % Trace all the last MQTT subscribe. Peek read the last data of a topic but don't delete data read
                    writeToScreenAndFile(peek(mqtt_client));
                    break;
                end
            end
        end

        % Trace data to send in MQTT server
        writeToScreenAndFile(sprintf('MQTT Topic: "application/2/device/%s/tx"', DEVEUI_HEX));
        writeToScreenAndFile(sprintf('MQTT Message: {"confirmed":false,"fPort":%d,"data":"%s"}', fport, payload_to_down));

        % Send MQTT message for DOWN Frame 
        write_MQTT_message(mqtt_client, ['application/2/device/' DEVEUI_HEX '/tx'], ['{"confirmed":false,"fPort":' int2str(fport) ',"data":"' payload_to_down '"}']);
        
%         % BEGIN OPTION
%         % Uncomment to test DOWNLINK frame received during serial transfer
%         % To busy the serial port
%         try
%             send_cmd(s_stm, 'AT?');
%         catch
%             writeToScreenAndFile('ERROR: Serial Tx Out')
%         end
%         % END OPTION

        % Verify message is received by the STM device with the right data
        data_received_down = "";
        check_data = lower(strjoin(string(dec2hex(random_data, 2)), ''));
        size_of_check_data = string(dec2hex(strlength(check_data) / 2, 2));
        
        % Read MQTT server command send by the Chirpstack server
        MQTT_data = peek(mqtt_client, Topic=['application/2/device/' DEVEUI_HEX '/tx']);

        % We are waiting a serial data like: "+EVT:<port>:<size>:<payload>"
        while( 1 )
            data_received_down = readline(s_stm);
            writeToScreenAndFile(sprintf("Serial data Received: %s", data_received_down));
            % 'Empty' means that a timeout occurs on the serial reception
            if ( ~isempty(data_received_down) )
                % Data received should be the same as the data send to the MQTT server
                if ( contains(data_received_down, "EVT:") )
                    if ( contains(data_received_down, strcat("EVT:", int2str(fport), ":", size_of_check_data, ":", check_data )) )
                        % Read the 2 other lines to clear the buffer
                        data_received_down = readline(s_stm);
                        writeToScreenAndFile(sprintf("Serial data Received: %s", data_received_down));
                        data_received_down = readline(s_stm);
                        writeToScreenAndFile(sprintf("Serial data Received: %s", data_received_down));
    
                        writeToScreenAndFile("OK: DOWNLINK frame Received");
                        break;
                    else
                        writeToScreenAndFile("WARNING: Unexpected event received (line above)");
                    end
                end
            else
                writeToScreenAndFile(sprintf("ERROR: DOWNLINK frame NOT Received after timeout of %d", s_stm.Timeout));
                % Trace all the last MQTT subscribe
                writeToScreenAndFile(peek(mqtt_client));
                % Data processing only if something is received
                if ( isempty(MQTT_data) )
                    writeToScreenAndFile("ERROR: No MQTT DOWN command sent by the Chirpstack server");
                else
                    writeToScreenAndFile("ERROR: Device don't received data sent by the Chirpstack server");
                    % Print data in file
                    writeToScreenAndFile(sprintf("MQTT Data received: %s", MQTT_data.Data));
                    % Pause to be sure all data are received by the device and check if there is
                    pause(10);
                    if ( s_stm.NumBytesAvailable > 1 )
                        writeToScreenAndFile(sprintf("Serial data Received: %s", read(s_stm, s_stm.NumBytesAvailable,'string')));
                    end
                end
                break;
            end
        end
    end
end

