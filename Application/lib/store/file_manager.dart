import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

/* ------------------------------------------------------------------------- *
 *                            Singletons
 * ------------------------------------------------------------------------- */

/// Singleton to get access to storage utility
class CoordinatesStorageSingleton {

  static final BaseStorageCoordinatesUtils _singleton = new JSONCoordinatesStorage();

  CoordinatesStorageSingleton();

  static BaseStorageCoordinatesUtils getInstance() {
    return _singleton;
  }
}

/// Singleton to handle the storage of the pool of trajectories not yet sync with the server<br>
/// Change instantiation here if another method should be used in the future
class PoolTrajectoriesStorageSingleton {
  static final BaseStorageTrajectoryUtils _singleton = new JSONTrajectoryStorage();

  PoolTrajectoriesStorageSingleton();

  static BaseStorageTrajectoryUtils getInstance() {
    return _singleton;
  }
}

/// Singleton to handle the storage of the stay point geofence<br>
/// Change instantiation here if another method should be used in the future
class GeofenceStorageSingleton {
  static final BaseStorageGeofenceUtils _singleton = new JSONGeofenceStorage();

  GeofenceStorageSingleton();

  static BaseStorageGeofenceUtils getInstance() {
    return _singleton;
  }
}


/* ------------------------------------------------------------------------- *
 *                          Abstract interface
 * ------------------------------------------------------------------------- */

/// An abstract call to build a custom utility for for coordinates storage upon.
abstract class BaseStorageCoordinatesUtils {

  Future<String> readCoordinatesList();
  Future<File> storeCoordinatesList(String coordList);
  Future<bool> clean();
}

/// An abstract call to build a custom utility for trajectories storage upon.
abstract class BaseStorageTrajectoryUtils {
  Future<String> readPoolTrajectories();
  Future<File> storePoolTrajectories(String poolTrajectoriesAsJson);
  Future<bool> clean();
}

/// An abstract call to build a custom utility for geofences storage  upon.
abstract class BaseStorageGeofenceUtils{
  Future<bool> isGeofenceSet();
  Future<String> readCurrGeofence();
  Future<File> storeGeofence(String geoFenceAsJson);
  Future<File> replaceGeofence(String geoFenceAsJson);
  Future<bool> clean();
}


/* ------------------------------------------------------------------------- *
 *                       Option 1: Secured storage
 * ------------------------------------------------------------------------- */

/// @improvement idea: Define classes like below with encryption feature (see session)
/// Not hard to do at all, easy to implement.


/* ------------------------------------------------------------------------- *
 *                         Option 2: Raw JSON storage
 * ------------------------------------------------------------------------- */

/// Store coordinates in the app directory. Then, they will be synchronized with the server.
/// <br>Writing is overriding.
class JSONCoordinatesStorage implements BaseStorageCoordinatesUtils {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/coordinates.json');
  }

  Future<String> readCoordinatesList() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        print("file does not yet exist -> create a new one");
        clean();
      }

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      print("[store/readCoordinatesList()] Error encountered : $e");
      return null;
    }
  }

  Future<File> storeCoordinatesList(String coordinatesListAsJson) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$coordinatesListAsJson');
  }

  Future<bool> clean() async {
    final file = await _localFile;
    await file.writeAsString('');
    return true;
  }
}


/// Store trajectories in the app directory. Then, they will be synchronized with the server. <br>
/// Writing is overriding.
class JSONTrajectoryStorage implements BaseStorageTrajectoryUtils{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/trajectory.json');
  }

  Future<String> readPoolTrajectories() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        print("file does not yet exist -> create a new one");
        clean();
      }

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      print("[store/readPoolTrajectories()] Error encontered : $e");
      return null;
    }
  }

  Future<File> storePoolTrajectories(String poolTrajectoriesAsJson) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$poolTrajectoriesAsJson');
  }

  Future<bool> clean() async {
    final file = await _localFile;
    await file.writeAsString('');
    return true;
  }
}


/// Store a geofence in the app directory. <br>
/// Writing is overriding
class JSONGeofenceStorage implements BaseStorageGeofenceUtils{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/geofence.json');
  }

  Future<String> readCurrGeofence() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        print("file does not yet exist -> create a new one");
        clean();
      }

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      print("[store/readGeofence()] Error encontered : $e");
      return null;
    }
  }

  Future<File> storeGeofence(String geofenceAsJson) async {
    final file = await _localFile;
    return file.writeAsString('$geofenceAsJson');
  }

  Future<File> replaceGeofence(String geofenceAsJson) async {
    return storeGeofence(geofenceAsJson);
  }

  Future<bool> clean() async {
    final file = await _localFile;
    await file.writeAsString('');
    return true;
  }

  Future<bool> isGeofenceSet() async{
    try {
      String geo = await readCurrGeofence();
    } on FormatException {
      print("That string didn't look like Json.");
      return false;
    } on NoSuchMethodError {
      print('That string was null!');
      return false;
    } catch (e) {
      print("File does not yet exist");
      return false;
    }
    return true;
  }
}

