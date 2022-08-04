function receivedSerialData(src,evt)
    data_received = readline(src);
    src.UserData(end+1) = data_received;
%     write(asyncBuff, data_received);
%     disp(data_received);
    disp(strcat("Data received: ", data_received));
    writeDataInFile("test.txt", data_received);
end