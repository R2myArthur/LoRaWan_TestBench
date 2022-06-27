%% connect serial
try
    clear s;
catch
end
s = init_serial('COM5', 9600, "CR");

%% initialize Device
resp = send_cmd(s, 'sys reset');
disp(['Reset:   ',resp]);

resp = send_cmd(s, 'mac reset 868');
disp(['MAC Reset:',resp]);

resp = send_cmd(s, 'mac set deveui 0004a30b001b062f');                        % 8-Byte, globally UID (use preprogrammed unique EUI)
disp(['set deveui: ',resp]);
resp = send_cmd(s, 'mac set appeui 0000000000000000');  
disp(['set appeui: ',resp]);

resp = send_cmd(s, 'sys get ver');
disp(['Version: ',resp]);
resp = send_cmd(s, 'mac get class');
disp(['Class: ',resp]);
resp = send_cmd(s, 'mac get status');
disp(['Status: ',resp]);
resp = send_cmd(s, 'mac get deveui');
disp(['deveui: ',resp]);
resp = send_cmd(s, 'mac get appeui');
disp(['appeui: ',resp]);

resp = send_cmd(s, 'mac set appkey d6070b81c623f5fd6e6779be634aef86');
disp(['set appkey: ',resp]);

%% Send Data
resp = send_cmd(s, 'mac join otaa');
disp(['join: ',resp]);
resp = readline(s);
disp(['join: ',resp]);


