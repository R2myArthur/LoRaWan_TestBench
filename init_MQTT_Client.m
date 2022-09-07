%% Create MQTT client connected to broker and subscribe all topics
% Param
%   brokerAddress : string : host name or IP address of the MQTT broker (ex: "tcp://128.131.85.183")
%   port          : int    : Socket port number to use when connecting to the MQTT broker (ex: 1883)
%
% Return a the MQTT interface

function mqClient = init_MQTT_Client(brokerAddress, port)
    % Create new MQTT client
    mqClient = mqttclient(brokerAddress, Port = port);

    % Connection for 24h if no exchange
%     KeepAliveDuration=minutes(24*60);
    
    % Connection to the server
    mqClient.Connected;

    % Subscribe to all subject
    subscribe(mqClient, '#');
    
    % Display subscriptions
    disp("Subscriptions: ");
    disp(mqClient.Subscriptions);
end
