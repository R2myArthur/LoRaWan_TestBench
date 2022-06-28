%% connect serial
try
    clear s2;
catch
end
s2 = init_serial('COM5', 9600, "CR");

%% initialize Device
% Reset board
send_cmd(s2, 'ATZ');

% Show help
send_cmd(s2, 'AT?');

% Set APP EUI
send_cmd(s2, 'AT+APPEUI=01:01:01:01:01:01:01:01');
% Set Dev Eui
send_cmd(s2, 'AT+DEUI=31:31:35:38:60:37:8F:18');
% Set Dev Addr
send_cmd(s2, 'AT+DADDR=20:3A:06:2F');
% Set APP KEY
send_cmd(s2, 'AT+APPKEY=2B:7E:15:16:28:AE:D2:A6:AB:F7:15:88:09:CF:4F:3C');
% Set NwkKey
send_cmd(s2, 'AT+NWKKEY=2B:7E:15:16:28:AE:D2:A6:AB:F7:15:88:09:CF:4F:3C');

%% Join Network

% Join the network
send_cmd(s2, 'AT+JOIN=1');

%% Send Data
send_cmd(s2, 'AT+SEND=1:0:ABCDEF');

%% Send Data confirmed
send_cmd(s2, 'AT+SEND=1:1:FEDCBA');

