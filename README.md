# docker-experience-builder
ESRI ArcGIS "Experience Builder, Developer Edition" running in Docker.

Esri instructions for installing are here: https://developers.arcgis.com/experience-builder/guide/install-guide/

'''2023-12-07''' installed version 1.13 November 2023

'''2023-02-07''' updates for version 1.10 (November 2022). This release took more work.

Bumped from node 12 to node 18 (in Dockerfile.*)
Change multer from 1.44 to 1.44-lts-1 in server/package.json 
and delete server/package-lock.json and client/package-lock.json to address it. (Might not even need to change
multer after deleting package-lock.json.)

Added --force to "npm audit fix" in Dockerfile.client to address this quill error, 

```bash
quill  <=1.3.7
Severity: moderate
Cross-site Scripting in quill - https://github.com/advisories/GHSA-4943-9vgg-gr5r
No fix available
node_modules/quill
```

'''2022-04-21''' Updates for version 1.8. Using node version 12. Very few changes from 1.7.

'''2022-01-18''' Updates for version 1.7. Using node version 12.

I can't tell what the license requirements are on Experience Builder.
I assume it needs to be locked down so I do not include an automatic
downloader in this project for now.

## Prerequisites

* A working copy of ArcGIS Enterprise Portal or an ArcGIS Online "organization" account.
* A computer that can run the docker container.

The "organization" account can be one that you set up with the (free)
developer program.  Go to https://developers.esri.com/ -- the
"personal" account you get at arcgis.com is pretty much useless
because it does not allow the full range of features you need for
creating content.

## Set up

### Download and unzip

Find the ZIP file at the ESRI site
[Experience Builder](https://developers.arcgis.com/experience-builder/) Sign in
and then look in Downloads until you find Experience Builder and
download the zip file arcgis-experience-builder-VERSION.zip.

Unzip the downloaded file. When you are done there should be a folder here called ArcGISExperienceBuilder.

I used to put the "unzip" step inside each Dockerfile, but then I wanted to make some modifications
to the EXB code before building, so I now unzip at the command line and do my mods before creating the
Docker images. It turned out this made the Dockerfiles a lot simpler too, so it was a good thing all around.

#### Offline option

TODO LATER

I wanted to see what it's like using the "offline" version, which means adding the JSAPI.
Refer to https://developers.arcgis.com/experience-builder/guide/install-guide/

Download the API from here https://developers.arcgis.com/javascript/latest/install-and-set-up/


### Networking note

I run this service directly on the local network (no proxy) at the default ports. You might want to run it some other way.

Port 3001 uses a self-signed certificate. If you run a reverse proxy for external access you could use port 3000 which is not encrypted.

## Add Matomo tracking code

In ArcGISExperienceBuilder/client/dist/index.html I add the Matomo
code block so that any apps built with EXB will be tracked for me.
My Matomo code block looks like this. I insert it just ahead of
the end tag for the "head" block.

```bash
<!-- Matomo -->
<script>
  var _paq = window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="https://PUTYOURURLHERE.gov/";
    _paq.push(['setTrackerUrl', u+'matomo.php']);
    _paq.push(['setSiteId', '1']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<!-- End Matomo Code -->
```

## Build image

This command will build new images for exb-server and exb-client.
If you do the Matomo hack later on, you will have to do a new build.

    docker compose build

## Run

Currently I am using Docker Compose for this, so, to launch it I use:

    docker compose up -d

This starts two containers, "experience-builder_server_1"
and "experience-builder_client_1". The "server" is the web server
that you connect to via browser. It is my understanding that the
so-called "client" just runs webpack to compile your applications.

To get EXB to stop, use

    docker-compose down

### Volumes for storage

The server and client containers share the same "public" folder.
I think they both need to have write access on the folder.
After initial set up your settings will be in
public/signin-info.json. The apps you create will be stored
in public/apps/.

## Portal (or ArcGIS.com) set up

See the official docs at https://developers.arcgis.com/experience-builder/guide/getstarted.htm

Once EXB is up and running you still have to connect it to an Esri server.
Go to either your ArcGIS Enterprise Portal or your ArcGIS.com developer account to create a new AppId.

In your Portal (or https://myorganization.maps.ArcGIS.com/),

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

    docker exec -it exb "rm signininfo.json"

Then refresh the browser connection to EXB and it should prompt again for AppId.

## Maybe I should be worried about these messages?

There are some "npm WARN deprecated" messages that pop up during the build phase
but they don't seem to hurt anything. Not yet.
