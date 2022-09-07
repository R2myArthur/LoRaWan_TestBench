%% Configure STM Board with LORA parameters
% Param
%   serial : Serialport object : Connection to the port
%   devEUI : String            : Device EUI in accordance with the server (ex: '31:31:35:38:60:37:8F:18')
%   appEUI : String            : Application EUI OTAA configured on the server (ex: '01:01:01:01:01:01:01:01')
%   appKey : String            : Application Key OTAA configured on the server (ex: 2B:7E:15:16:28:AE:D2:A6:AB:F7:15:88:09:CF:4F:3C')
%
% Return Nothing

function stm_config(s_stm, devEUI, appEUI, appKey)    
    % Set APP EUI
    send_cmd(s_stm, ['AT+APPEUI=' appEUI]);
    data_received = readline(s_stm);
    data_received = readline(s_stm);
    writeToScreenAndFile(sprintf("APPEUI: %s", data_received));
    % Set Dev Eui
    send_cmd(s_stm, ['AT+DEUI=' devEUI]);
    data_received = readline(s_stm);
    data_received = readline(s_stm);
    writeToScreenAndFile(sprintf("DEVEUI: %s", data_received));
    % Set APP KEY
    send_cmd(s_stm, ['AT+APPKEY=' appKey]);
    data_received = readline(s_stm);
    data_received = readline(s_stm);
    writeToScreenAndFile(sprintf("APPKEY: %s", data_received));
    % Set Duty cycle OFF
    send_cmd(s_stm, 'AT+DCS=0'); % 0= deactivate; 1= activate
%     data_received = readline(s_stm);
%     data_received = readline(s_stm);
%     data_received = readline(s_stm);
    writeToScreenAndFile("DUTY CYCLE DEACTIVATE");
    % TODO
    % Set verbose level
%     send_cmd(s_stm, 'AT+VL=1');
%     data_received = readline(s_stm);
%     data_received = readline(s_stm);
%     writeToScreenAndFile(sprintf("VERBOSE LV1: %s", data_received));
    % Time for the device to change parameters
    pause(3);
end