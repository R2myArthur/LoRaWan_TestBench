
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
    send_cmd(s_stm, 'AT+DCS=0');
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
end