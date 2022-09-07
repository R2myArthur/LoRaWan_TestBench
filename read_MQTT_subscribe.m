% Read available messages from MQTT topic
% Param
%   mqttC   : Client object     : MQTT client connected to a MQTT broker
%   topic   : String            : Topic concerned (ex: "application/2/device/3131353860378f18/tx")
%
% Return A timetable of data read

function dataMQTT = read_MQTT_subscribe(mqttC, topic)
    dataMQTT = read(mqttC, Topic=topic);
%     disp("Data read: ");
%     disp(dataMQTT);
end
