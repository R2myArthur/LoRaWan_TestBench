%% function
% <s>: Port COM where to send the data
% <type>: string representing the uplink payload type, either cnf or uncnf (cnf – confirmed, uncnf – unconfirmed)
% <portno>: decimal number representing the port number, from 1 to 223
% <data>: hexadecimal value. The length of <data> bytes capable of being transmitted are dependent upon the set data rate (for further details, refer to the LoRaWAN™ Specification V1.0.2)
%
% Response: this command may reply with two responses. The first response will be 
% received immediately after entering the command. In case the command is 
% valid (ok reply received), a second reply will be received after the end of the 
% uplink transmission
function rn2483_sendData(s, type, portno, data)
    send_cmd(s, ['mac tx ' type ' ' portno ' ' data]);
end
