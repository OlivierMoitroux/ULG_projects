package controllers;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import play.mvc.*;
import views.html.*;


//DEPRECIATE
public class InitDB extends Controller{

	public Result install() {
		DataBase db = new DataBase();
		if (!db.connect())
			return internalServerError("Impossible to connect to the database");

		db.createTableClient();
		db.createTableTrajectory();
		db.createTablePlace();
		db.createTableHabit();

		return ok("Tables installed");
	}
}
