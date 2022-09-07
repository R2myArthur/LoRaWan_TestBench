%% Send message to a MQTT Broker
% Param
%   mqttC    : Client object : MQTT client connected to a MQTT broker
%   topic    : String        : Topic concerned (ex: "application/2/device/3131353860378f18/tx")
%   dataMQTT : String        : Data to include in DOWNLINK frame in Hexa string
%
% Return nothing

function write_MQTT_message(mqttC, topic, dataMQTT)
    write(mqttC, topic, dataMQTT)
%     disp("Data write: ");
%     disp(dataMQTT);
end