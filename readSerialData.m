function data = readSerialData(src,evt)
    data = readline(src);
    disp(['Data recevived: ', data]);
end