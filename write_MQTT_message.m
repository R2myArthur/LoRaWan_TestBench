function write_MQTT_message(mqttC, topic, dataMQTT)
    write(mqttC, topic, dataMQTT)
%     disp("Data write: ");
%     disp(dataMQTT);
end