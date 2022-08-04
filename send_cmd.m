function send_cmd(serial, cmd)
%     disp(['Send Cmd: ' cmd]);
    writeline(serial, cmd);
    pause(1/2); % Wait 500ms
end