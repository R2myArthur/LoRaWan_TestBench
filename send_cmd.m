%% Send a command on the specified Serial Port
% Param
%   serial : Serialport object : Connection to the port
%   cmd    : string            : Command to send to the device
%
% Return nothing

function send_cmd(serial, cmd)
%     fprintf('Send Cmd: %s\n', cmd);   % DEBUG
    writeline(serial, cmd);
%     pause(1/2); % DEBUG Wait 500ms
end