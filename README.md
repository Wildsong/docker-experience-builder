# docker-experience-builder
Run ESRI ArcGIS Experience Builder in a Docker container

2020-01-24-- As of today ESRI is at at Beta2 and that's what I support here.

ESRI GAVE US A USELESS BETA. You can use it to try out what they are developing but
you cannot download or deploy a project. Maybe it will start to be useful at beta 3??
Now that I've seen it, I am going to wait it out.

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

exb_public will be mounted in the server, and the first time you run
you will be prompted for portalName and clientId. Those will be stored into
the exb_public volume as signin-info.json. Then you will give approval
on the next page and the second file, setting.json, will be written into
an internal location client/dist/builder/setting.json.

On subsequent restarts the server should remember everything.

Your work will be saved under the exb_public volume in the apps folder,
but these files are not intended for human consumption :-) only for EXB.

## Portal set up

On the Portal side you have to set up a new App and get the AppId. 

In Portal,
* Content tab->My Content
* Add Item->Application
* Type of application: Web Mapping
* Purpose: Ready to use
* API: Javascript
* URL: https://yourdocker:3001/
* Title: whatever you like
* Tags: whatever...
Then you have to co into the settings for the new "Web Mapping Application"
and "register" to get an AppId. Under "App Registration",
* App Type: Browser
* Redirect URI: I used http://yourdocker:3001/ (no domain). You can put in more than one...

That gets you the AppId which you can take back to the EXB web page.

Once EXB is running you still have to connect it to Portal.
Open a browser (e.g. http://yourdockerserver:3001/) and
enter the URL of your Portal and an AppId (from Portal).

To change the client ID later, I had to delete signininfo.json
file from the Docker and restart it.
With the docker running from another command line I do this:

    docker exec -it exb "rm signininfo.json"

Then refresh the browser connection to EXB and it should prompt again for AppId.

