%% Test for erreur UPLINK Frame ("AT_BUSY_ERROR")
flush(s_stm);

fport = 66;
confirmation = '0';
payload_to_up = "F261B19AC69760D939CCFF48B5AA6A7FF2F4BB620A95905AE19F9F4B13";

while 1
    send_cmd(s_stm, strcat('AT+SEND=', int2str(fport), ':', confirmation, ':', payload_to_up));

    c = 0;
    while c < 11
        rsp = readline(s_stm);
        fprintf('%s\n', rsp);
        if isequal(rsp, 'AT_BUSY_ERROR')
            flush(s_stm);
            break;
        end
%         if isempty(rsp)
%             pause(2);
%             flush(s_stm);
%         end
        if ~isempty(rsp) && rsp(1)=='+'
        else
            c = c + 1;
        end
    end

    if s_stm.NumBytesAvailable
        error('buffer not empty');
    end

%     pause(4);
end