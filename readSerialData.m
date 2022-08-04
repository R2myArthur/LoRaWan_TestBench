function data = readSerialData(src,evt)
    % Initialize a string array with an overestimated large array 
    data = strings(1,100);
    i=1;
    % Read all data in the buffer
    while (src.NumBytesAvailable > 1)
        try
            data(i) = readline(src);
            disp([i data(i)]);
            i =i+1;
        catch
            % If data is unreadable, discard it
            flush(src);
            break;
        end
    end
    % Display only data received
    data = data(:,1:i-1);
    disp(['Data recevived: ', data]);
end