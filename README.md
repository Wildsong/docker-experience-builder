# docker-experience-builder
Create a Docker image for ESRI ArcGIS Experience Builder

2021-12-03 As of today ESRI is at version 1.6 and that's what I support here.

*********************************************************
NOT WORKING
I don't know how to run the two part thing with a separate
server and webpack client in dockers yet so for now I am just
running it on the host
*********************************************************


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

## Set up

### Download

This project will not download the zip from Esri.
Use your ESRI account to do the download first.

Find the ZIP file at the ESRI site [Experience Builder](https://developers.arcgis.com/experience-builder/) 
Sign in and then look in the API/SDK link until you find Experience Builder and download it.

When done you should have a file "arcgis-experience-builder-1.6.zip".
If they have changed the name again, update it in docker-compose.yml.

### Networking note

I run this service directly on the local network (no proxy) at the default ports.
You might do it some other way.  

Port 3001 uses a self-signed certificate and is exposed on the internal network.
You could set up port 3000 if you wanted to put a reverse proxy in front of it.

## Build image

```bash
docker-compose build
```

## Run

Currently I am using Docker Swarm for this, so, to launch it I use:

```bash
docker stack deploy -c docker-compose.yml exb
```

To get it to stop, use

```bash
docker stack remove exb
```

### Client install

I don't know what the client is yet, I just note that these instructions exist...

```bash
docker exec -ti exb_tab<TAB> bash
cd client
npm ci
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

```bash
docker exec -it exb "rm signininfo.json"
```

Then refresh the browser connection to EXB and it should prompt again for AppId.

