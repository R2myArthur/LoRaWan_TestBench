%% Function to confugre an end device RN2483 from Microchip
% Param band     Band of frequency : '868' or '433'
% Param devEUI
% Param appEUI
% Param appKey
% Param class

function rn2483_config(s, band, devEUI, appEUI, appKey, class)
    % Reset Device
    send_cmd(s, 'sys reset');
    readSerialData(s);
    send_cmd(s, ['mac reset ' band]);
    readSerialData(s);

    % Set Key and ID
    send_cmd(s, ['mac set deveui ' devEUI]);                        % 8-Byte, globally UID (use preprogrammed unique EUI)
    readSerialData(s);
    send_cmd(s, ['mac set appeui ' appEUI]);
    readSerialData(s);
    send_cmd(s, ['mac set appkey ' appKey]);
    readSerialData(s);
    send_cmd(s, ['mac set class ' class]);
    readSerialData(s);
    
    % Display parameters
    send_cmd(s, 'sys get ver');
    readSerialData(s);
    send_cmd(s, 'mac get class');
    readSerialData(s);
    send_cmd(s, 'mac get status');
    readSerialData(s);
    send_cmd(s, 'mac get deveui');
    readSerialData(s);
    send_cmd(s, 'mac get appeui');
    readSerialData(s);
end