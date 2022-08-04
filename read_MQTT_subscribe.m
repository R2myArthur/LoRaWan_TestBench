function dataMQTT = read_MQTT_subscribe(mqttC, topic)
    dataMQTT = read(mqttC, Topic=topic);
%     disp("Data read: ");
%     disp(dataMQTT);
end
