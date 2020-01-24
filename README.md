# docker-experience-builder
Create a Docker image for ESRI ArcGIS Experience Builder

2020-01-24-- As of today ESRI is at at Beta2 and that's what I support here.

I honestly can't tell what the license requirements are on Experience Builder
so I am assuming it needs to be locked down and not trying to include a downloader
in this project for now.


## Prerequisites 

* A working copy of ArcGIS Enterprise Portal or an ArcGIS Online "organization" account.
* A server that can run the docker container. 

The "organization" account can be one that you set up with the (free)
developer program.  Go to https://developer.esri.com/ -- the
"personal" account you get at arcgis.com is pretty much useless.


# Set up

## Download and unzip.

This project will not download licensed code from Esri. (Not yet anyway.)
Use your ESRI account to do the download first.

Find the ZIP file at the ESRI site [Web App Builder](https://developers.arcgis.com/web-appbuilder/)Go to https://earlyadopter.esri.com/home.html and sign in and then 
click through until you find Experience Builder and download it.

Unzip the file here in this folder.

When done you should have a folder "arcgis-experience-builder-beta2".

## Networking note

I run this service directly on the network (no proxy) at the default port.
You might do it some other way.  There is an EXPOSE
line in the Dockerfile to expose the ports that it uses.

## Build image

```bash
docker-compose build
```

## Run

```bash
docker-compose up
```

"Restart" is built in to the docker-compose.yml file so
the service will restart every time you reboot the server. To get it to stop, use

```bash
docker-compose down
```

### Volumes for storage

You will want a couple volumes hooked up to the container, one for
widgets and one for the app files that will be shared with a web
server.

In development I am keeping them here in the folder, widgets and apps.

## Portal set up

Once it is up and running you still have to connect it to Portal.
Connect to EXB first from a browser (e.g. http://yourdockerserver:3001/webappbuilder/) and
enter the URL of your Portal and an AppId (from Portal). On the Portal
side you have to set up a new App and get the AppId. Complete
relatively good instructions are on the ESRI web site under Quick Start.

In Portal,
* Content tab->My Content
* Add Item->Application
* Type of application: Web Mapping
* Purpose: Ready to use
* API: Javascript
* URL: http://yourdocker:3001/exb
* Title: whatever you like
* Tags: whatever...
Then you have to co into the settings for the new "Web Mapping Application"
and "register" to get an AppId. Under "App Registration",
* App Type: Browser
* Redirect URI: I used http://yourdocker.yourdomain

That gets you the AppId which you can take back to the WAB web page.

To change the client ID later, I had to delete signininfo.json
file from the Docker and restart it.
With the docker running from another command line I do this:

    docker exec -it exb "rm signininfo.json"

Then refresh the browser connection to EXB and it should prompt again for AppId.

