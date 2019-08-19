package controllers;
import play.mvc.*;

import java.io.File;

import static play.libs.Json.newObject;


public class GetConfig extends Controller{
    public Result getCongfig(){
        System.out.println("Sending the config file");
        File config = new File("/home/shared/config/config");//Server path
        if(!config.exists())
            return Results.internalServerError("Unable to access the database.");

        return ok(config);
    }
}
