package controllers;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import objects.*;

import java.util.ArrayList;
import java.util.List;

import play.mvc.*;

import java.util.List;

public class PostTrajectories extends Controller{
    public Result post() {
        System.out.println("Receiving trajectories");

        DataBase db;
        Client client;
        Trajectory traj;

        db = new DataBase();
        if (!db.connect())
            return internalServerError("Unable to access the database.");

        //Reading the header for the connection

        String headers = request().header("Authorization").toString();
        String tempWord = "Optional";
        headers = headers.replaceAll(tempWord,"").replaceAll("\\[", "").replaceAll("\\]","");;
        System.out.println(headers);

        ObjectMapper mapper = new ObjectMapper();
        try {
            client = mapper.readValue(headers, Client.class);
        } catch (Exception e) {
            System.out.println(e);
            return badRequest("Not usable header");
        }

        if (!CheckPassword(client, db)) {
            return unauthorized("Password or userName incorrect");
        }

        //Retrieving the client ID

        client.id = db.getClientID(client);
        if (client.id < 0)
            return internalServerError("Internal database error");

        int count = db.getClientCounter(client.id);
        if (count < 0)
            return internalServerError("Internal database error");

        //Reading the body

        String json;
        try {

            json = request().body().asJson().toString();
        } catch (Exception e) {
            return badRequest(e.toString());
        }

        if (json == null){
            db.disconnect();
            return badRequest("Expecting Json file in the body");
        }

        mapper = new ObjectMapper();
        MapperTrajectory mapTraj = new MapperTrajectory();
        TypeReference<List<MapperTrajectory>> typeRef = new TypeReference<List<MapperTrajectory>>() {
        };
        //List<MapperTrajectory> trajList = new ArrayList<MapperTrajectory>();
        ListMapTraj lTraj = new ListMapTraj();

        try {
            System.out.println(json);
            lTraj = mapper.readValue(json, ListMapTraj.class);

        } catch (Exception e) {
            db.disconnect();
            System.out.println(e);
            return badRequest("Error while parsing");
        }

        for (MapperTrajectory mt : lTraj.trajectories) {
            Place placestart = new Place(mt.startStayPoint.latitude, mt.startStayPoint.longitude, mt.startTime);
            Place placeend = new Place(mt.endStayPoint.latitude, mt.endStayPoint.longitude, mt.endTime);
            db.insertPlace(placestart, client.id);
            db.insertPlace(placeend, client.id);
            db.insertTrajectory(mt, client.id);
            count++;
        }
        db.editCounter(count, client.id);
        db.disconnect();
        return ok("Trajectories received");
    }


    private Boolean CheckPassword(Client client, DataBase db){
        System.out.println("testing password");
        String pw = db.selectPasswor(client.username);
        pw = pw.replaceAll("\\s+","");
        return client.password.equals(pw);
    }
}