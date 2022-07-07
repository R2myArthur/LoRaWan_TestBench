function data = readSerialData(src,evt)
    data = read(src, src.NumBytesAvailable, 'string');
    disp(['Data recevived: ', data]);
end