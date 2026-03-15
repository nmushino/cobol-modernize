package com.redhat.output;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.util.List;

@Path("/messages")
public class KafkaViewerResource {

    @Inject
    KafkaViewer viewer;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<Integer> getMessages() {
        return viewer.getMessages();
    }
}