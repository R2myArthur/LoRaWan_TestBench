%% connect serial
try
    clear s;
catch
end
s = init_serial('COM6', 57600, "CR/LF");

%% initialize Device
send_cmd(s, 'sys reset');

send_cmd(s, 'mac reset 868');
send_cmd(s, 'mac set deveui a2ef0680c6610dfc');                        % 8-Byte, globally UID (use preprogrammed unique EUI)
send_cmd(s, 'mac set appeui 0000000000000000');  
send_cmd(s, 'mac set appkey d6070b81c623f5fd6e6779be634aef86');

send_cmd(s, 'sys get ver');
send_cmd(s, 'mac get class');
send_cmd(s, 'mac get status');
send_cmd(s, 'mac get deveui');
send_cmd(s, 'mac get appeui');


%% Join chirpstack
send_cmd(s, 'mac join otaa');


%% Send Data
pause(8);
send_cmd(s, 'mac tx uncnf 4 AAAAAA');

