# docker-experience-builder
ESRI ArcGIS "Experience Builder, Developer Edition" running in Docker.

2022-01-18 Updates for version 1.7. Using node version 12.

I can't tell what the license requirements are on Experience
Builder. I assume it needs to be locked down so I do not
include an automatic downloader in this project for now.

## Prerequisites 

* A working copy of ArcGIS Enterprise Portal or an ArcGIS Online "organization" account.
* A computer that can run the docker container.

The "organization" account can be one that you set up with the (free)
developer program.  Go to https://developers.esri.com/ -- the
"personal" account you get at arcgis.com is pretty much useless because it does not allow the full range of features you need for creating content.

## Set up

### Download

Find the ZIP file at the ESRI site [Experience Builder](https://developers.arcgis.com/experience-builder/) 
Sign in and then look in the API/SDK link until you find Experience Builder and download it.

When done you should have a file "arcgis-experience-builder-1.7.zip".
(If they have released a newer version, update docker-compose.yml.)

### Networking note

I run this service directly on the local network (no proxy) at the default ports. You might want to run it some other way.

Port 3001 uses a self-signed certificate. If you run a reverse proxy for external access you could use port 3000 which is not encrypted.

## Build image

```bash
docker-compose build
```

## Run

Currently I am using Docker Compose for this, so, to launch it I use:

```bash
docker-compose up -d
```

This starts two containers, "experience-builder_server_1"
and "experiece-builder_client_1". The "server" is the web server
that you connect to via browser. It is my understanding that the
so-called "client" just runs webpack to compile your applications.

To get EXB to stop, use

```bash
docker-compose down
```

### Volumes for storage

Currently there is just one container in use, and with
this docker-compose.yml it will be mounted onto the local public
folder. After initial set up your settings will be in
public/signin-info.json. After creating apps, they will be stored
in public/apps/.

## Portal (or ArcGIS.com) set up

See the official docs at https://developers.arcgis.com/experience-builder/guide/getstarted.htm

Once EXB is up and running you still have to connect it to an Esri server.
Go to either your ArcGIS Enterprise Portal or your ArcGIS.com developer account to create a new AppId.

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

Connect to EXB from a browser (e.g. https://yourdockerserver:3001/) and enter the URL of your server (Portal or ArcGIS.com) and the AppId you just created.

To change the client ID later, I had to delete signininfo.json
file from the Docker and restart it.
With the docker running from another command line I do this:

```bash
docker exec -it exb "rm signininfo.json"
```

Then refresh the browser connection to EXB and it should prompt again for AppId.
