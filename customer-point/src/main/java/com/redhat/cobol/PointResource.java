package com.redhat.cobol;

import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.io.*;

@Path("/customerpoint")
public class PointResource {

    @POST
    @Consumes(MediaType.TEXT_PLAIN)
    @Produces(MediaType.TEXT_PLAIN)
    public String calcPoint(String amount) throws Exception {

        ProcessBuilder pb = new ProcessBuilder("/app/customer-point");
        Process process = pb.start();

        OutputStream os = process.getOutputStream();
        os.write((amount + "\n").getBytes());
        os.flush();
        os.close();

        BufferedReader reader =
                new BufferedReader(new InputStreamReader(process.getInputStream()));

        String result = reader.readLine();

        process.waitFor();

        return result;
    }
}