# docker-experience-builder
Create a Docker image for ESRI ArcGIS Experience Builder

2020-09-23 As of today ESRI is at version 1.1 and that's what I support here.

I can't tell what the license requirements are on Experience
Builder so I am assuming it needs to be locked down and so I am not
trying to include a downloader in this project for now.

## Prerequisites 

* A working copy of ArcGIS Enterprise Portal or an ArcGIS Online "organization" account.
* A server that can run the docker container. 

The "organization" account can be one that you set up with the (free)
developer program.  Go to https://developers.esri.com/ -- the
"personal" account you get at arcgis.com is pretty much useless because
it does not allow the full range of features you need for creating content.

# Set up

## Download.

This project will not download the zip from Esri.
Use your ESRI account to do the download first.

Find the ZIP file at the ESRI site [Experience Builder](https://developers.arcgis.com/experience-builder/) 
Sign in and then look in the API/SDK link until you find Experience Builder and download it.

When done you should have a file "arcgis-experience-builder-1.1.zip".
If they have changed the name again, update it in docker-compose.yml.

## Networking note

I run this service directly on the local network (no proxy) at the default ports.
You might do it some other way.  

Port 3000 would be used if you want to put a reverse proxy in front of it.
Port 3001 uses a self-signed certificate and is exposed on the internal network.

## Build image

```bash
docker-compose build
```

## Run

```bash
docker-compose up -d
```

"Restart" is built in to the docker-compose.yml file so
the service will restart every time you reboot the server. To get it to stop, use

```bash
docker-compose down
```

### Volumes for storage

You will want a couple volumes hooked up to the container, one for
widgets and one for the app files that will be shared with a web
server. The provided docker-compose file will create them automatically.

## Portal (or ArcGIS.com) set up

See the official docs at https://developers.arcgis.com/experience-builder/guide/getstarted.htm

Once EXB is up and running you still have to connect it to an Esri server.
Go to either your ArcGIS Enterprise Portal or your ArcGIS.com developer account
to create a new AppId.

In Portal (or https://myorganization.maps.ArcGIS.com/),
* Content tab->My Content
* Add Item->Application
* Type of application: Web Mapping
* Purpose: Ready to use
* API: Javascript
* URL: https://localhost:3001/  (or you might use something else besides localhost)
* Title: whatever you like
* Tags: whatever...
Then you have to go into the settings for the new "Web Mapping Application"
and "register" to get the AppId. Under "App Registration",
* App Type: Browser
* Redirect URI: I used https://localhost:3001/
That gets you the AppId which you can take back to the EXB web page.

Connect to EXB from a browser (e.g. https://yourdockerserver:3001/) and
enter the URL of your server (Portal or ArcGIS.com) and the AppId you just created.

To change the client ID later, I had to delete signininfo.json
file from the Docker and restart it.
With the docker running from another command line I do this:

    docker exec -it exb "rm signininfo.json"

Then refresh the browser connection to EXB and it should prompt again for AppId.

