## Compiled version of the app
The application source code is on the *application* branch. Here are the compiled version of the app for convenience:

* ``app-debug.apk``: the app submitted the 9th May. Not renamed, normally meta data untouched.
* ``app-release.apk``: the application for the lambda person (no dev tools)
* ``app-dev.apk``: the application for the beta testers and the developers (dev tools accessible).

## About the submission

The submit of the 9th of May is perfectly functional. In doubt we weren't able to make little cosmetic patches after this date, we let this original file. 

Some groups decided to continue the development after this date. For this reason, new patches include:

* Ability to send trajectories with 4G if user accepts to (default to false in shared pref'). This helps testing as locally stored trajectories have more chances to be flushed to the server.

* Ability to configure remotely the app to try to flush trajectories to the server as soon as the internet connection is recovered

* Forgot comments removed

* When server unavailable while consult remote data, the error message is now relevant (ctrl+c, ctrl+v too much fixed)

* Updated config file for the app on the server

The git was sync *on time* on bitbucket the 9th May but resynchronized the 12th of May with the above modifications.

