%% connect serial
try
    clear s;
catch
end
s = init_serial('COM6', 57600, "CR/LF");

%% initialize Device
send_cmd(s, 'sys reset');
% disp(['Reset:   ',resp]);

send_cmd(s, 'mac reset 868');
% disp(['MAC Reset:',resp]);

send_cmd(s, 'mac set deveui 0004a30b001b062f');                        % 8-Byte, globally UID (use preprogrammed unique EUI)
% disp(['set deveui: ',resp]);
send_cmd(s, 'mac set appeui 0000000000000000');  
% disp(['set appeui: ',resp]);

send_cmd(s, 'sys get ver');
% disp(['Version: ',resp]);
send_cmd(s, 'mac get class');
% disp(['Class: ',resp]);
send_cmd(s, 'mac get status');
% disp(['Status: ',resp]);
send_cmd(s, 'mac get deveui');
% disp(['deveui: ',resp]);
send_cmd(s, 'mac get appeui');
% disp(['appeui: ',resp]);

send_cmd(s, 'mac set appkey d6070b81c623f5fd6e6779be634aef86');
% disp(['set appkey: ',resp]);

%% Send Data
send_cmd(s, 'mac join otaa');
disp(['join: ',resp]);
readline(s);
disp(['join: ',resp]);


