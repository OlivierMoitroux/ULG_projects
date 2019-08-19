# Readme

This folder holds the server code. We developed on top of the starter example provided for the Play tutorial. 
Thus, a lot of these files are the core of the Play framework (for example sbt and gradle files) and 
were left inside to be able to launch the server without additionnal download/installation. 

Our own files are in these directories :

In /app/controllers :
	-ReceiveJSONTestController.java (Transforms appropriate json file into custom java classes)
	-TestDB.java (Launches a series of operations on the databse)
	-Database.java (Used by TestDB)
In /app/position :
	-simple class definitions

Additionnaly we added a few lines
In /conf/application.conf (Added Database configuration)
In /conf/routes (Launch the appropriate java file depending of the incoming message url)
In build.sbt (Added a few dependencies to be able to use Play packages for the database) 

The ``config`` file in the ``config`` directory contains the JSON that is used by the server to configure remotely the application.


If you want to try and run the server, go with a terminal in the joined directory and use "sbt.bat run" if on Windows
or "./sbt run" if on Linux/Mac. However, you will probably encounter errors if the permissions are not set properly or if the database 
is not initiated. The first time sbt will need downloading/installing and can take some time. 