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
