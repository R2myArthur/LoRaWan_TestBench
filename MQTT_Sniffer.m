brokerAddress = "tcp://128.131.85.238";
port = 1883;
mqClient = mqttclient(brokerAddress, Port = port);
KeepAliveDuration=minutes(60);

mqClient.Connected;
% write(mqClient, "application/2/device/a2ef0680c6610dfc/rx", "Hello World")
% subscribe(mqClient, 'gateway/b827ebfffef6d838/command/config');
% % subscribe(mqClient, 'gateway/b827ebfffef6d838/event/stats');
% subscribe(mqClient, 'application/2/#');
% subscribe(mqClient, 'gateway/b827ebfffef6d838/#');
subscribe(mqClient, '#');

disp("Subscriptions: ");
disp(mqClient.Subscriptions);

dataTT = read(mqClient);
disp("Data read: ");
disp(dataTT);
% 
% data = peek(mqClient);
% disp("Data peek: ");
% disp(data);

%% Base 64
% res = base64decode('qqqq')
% res = base64encode(0xaaaaaa)

