
function stm_config(s_stm, devEUI, appEUI, appKey)    
    % Set APP EUI
    send_cmd(s_stm, ['AT+APPEUI=' appEUI]);
    readSerialData(s_stm);
    % Set Dev Eui
    send_cmd(s_stm, ['AT+DEUI=' devEUI]);
    readSerialData(s_stm);
    % Set APP KEY
    send_cmd(s_stm, ['AT+APPKEY=' appKey]);
    % Set APP KEY
    send_cmd(s_stm, 'AT+VL=1');
    readSerialData(s_stm);
end