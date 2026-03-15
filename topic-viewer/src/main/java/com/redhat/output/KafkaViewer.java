package com.redhat.output;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.reactive.messaging.Incoming;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@ApplicationScoped
public class KafkaViewer {

    private final List<Integer> messages = new CopyOnWriteArrayList<>();

    @Incoming("output-topic")
    public void consume(String msg) {
    
        int value = Integer.parseInt(msg.trim());
    
        messages.add(value);
    
        if (messages.size() > 100) {
            messages.remove(0);
        }
    }

    public List<Integer> getMessages() {
        return messages;
    }
}