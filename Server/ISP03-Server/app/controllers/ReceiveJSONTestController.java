package controllers;


import play.mvc.*;
import play.libs.Json.*;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.*;
import com.fasterxml.jackson.databind.node.ArrayNode;

import java.awt.*;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import position.*;
import controllers.*;


import views.html.*;

public class ReceiveJSONTestController extends Controller
{
	public Result parse() {
		//JsonNode json = request().body().asJson();
		/*
		if(json == null) {
			return badRequest("Expecting Json data");
		} else {
			String user = json.findPath("user").textValue();
			if(user == null) {
				return badRequest("Missing parameter [user]");
			}
			//ArrayNode itinary = new ArrayNode(json.withArray("itinary"));

			//System.out.println(itinary.get(1).findPath("user").asInt());
			if(!json.findPath("itinary").isArray()){
				return badRequest("Itinary not an array");
			}

			Vector<Point> itinary = new Vector<Point>();
			for (final JsonNode current : json.findPath("itinary")){
				itinary.add(new Point(current.findPath("latitude").asDouble(),
						current.findPath("longitude").asDouble(),
						current.findPath("date").textValue(),
						current.findPath("activity").asBoolean()));
			}
			
			/*DataBase dat = new DataBase();
			dat.connect();
			List<String> col= new ArrayList();
			col.add("datetimestart");
			col.add("datetimestop");
			col.add("travelingmean");
			col.add("iduser");
			
			ResultSet rs = dat.selectFromTable( "client", "id", "surname='"+user+"'");
			System.out.println(rs.getInt(1));
			dat.insertIntoTable("itinerary", "", null, val);*/
			
			

			/*return ok("First element : " + itinary.get(0).allAsString());/*
			
			//if(user != null) {
			//	return ok("Hello " + name);
			//}*/
		//}
		String coucou = "coucou";
		return ok(coucou);
	}

	// Do a method and a string template for each possible interactions

}