# Gem Dependencies
* bcrypt
* mongoid
* bootsnap
* bson_ext
* whenever
* geocoder
 
# Deployment
NEMTR deployment is still under construction.

## Deployment Notes
* The whenever gem interacts with the crontab on the server running NEMTR.  When deployed, the command `whenever --update-crontab` must be run to update the cronjobs with the listed jobs.  This ensures that rollover for schedules and database cleanup tasks run correctly.
* The database is linked through an API call to Mongo Atlas found in the config file for the application.  This conveniently also allows for the database to be interacted with directly through the Mongo Atlas portal should the database ever break.
* The appplication is linked to Google API through an specific API key, and should the API calls ever need to change a new key will likely need to be generated and implemented.
* Datetimes are being stored as local times (CT)
