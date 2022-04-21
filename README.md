# docker-experience-builder
ESRI ArcGIS "Experience Builder, Developer Edition" running in Docker.

2022-04-21 Updates for version 1.8. Using node version 12. Very few changes from 1.7.

2022-01-18 Updates for version 1.7. Using node version 12.

I can't tell what the license requirements are on Experience Builder.
I assume it needs to be locked down so I do not include 
an automatic downloader in this project for now.

## Prerequisites 

* A working copy of ArcGIS Enterprise Portal or an ArcGIS Online "organization" account.
* A computer that can run the docker container.

The "organization" account can be one that you set up with the (free)
developer program.  Go to https://developers.esri.com/ -- the
"personal" account you get at arcgis.com is pretty much useless because it does not allow the full range of features you need for creating content.

## Set up

### Download and unzip

Find the ZIP file at the ESRI site [Experience Builder](https://developers.arcgis.com/experience-builder/) 
Sign in and then look in the API/SDK link until you find Experience Builder and download it.

Then unzip the downloaded file. When you are done there should be a folder here called ArcGISExperienceBuilder.

Note, I used to put the "unzip" step inside each Dockerfile, but then I wanted to make some modifications
to the EXB code before building, so I now unzip at the command line and do my mods before creating the
Docker images. It turned out this made the Dockerfiles a lot simpler too, so it was a good thing all around.

### Networking note

I run this service directly on the local network (no proxy) at the default ports. You might want to run it some other way.

Port 3001 uses a self-signed certificate. If you run a reverse proxy for external access you could use port 3000 which is not encrypted.

## Matomo hack

In ArcGISExperienceBuilder/client/index.html I add the Matomo
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
    var u="https://webforms.co.clatsop.or.us/";
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

```bash
docker-compose build
```

## Run

Currently I am using Docker Compose for this, so, to launch it I use:

```bash
docker-compose up -d
```

This starts two containers, "experience-builder_server_1"
and "experience-builder_client_1". The "server" is the web server
that you connect to via browser. It is my understanding that the
so-called "client" just runs webpack to compile your applications.

To get EXB to stop, use

```bash
docker-compose down
```

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

## Maybe I should be worried,

### When building "server" I get these warnings

npm WARN @jest/core@27.2.5 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN @jest/reporters@27.2.5 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jest@27.2.5 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jest-cli@27.2.5 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jsdom@16.7.0 requires a peer of canvas@^2.5.0 but none is installed. You must install peer dependencies yourself.
npm WARN ts-node@10.3.0 requires a peer of @swc/core@>=1.2.50 but none is installed. You must install peer dependencies yourself.
npm WARN ts-node@10.3.0 requires a peer of @swc/wasm@>=1.2.50 but none is installed. You must install peer dependencies yourself.
npm WARN ws@7.5.5 requires a peer of bufferutil@^4.0.1 but none is installed. You must install peer dependencies yourself.
npm WARN ws@7.5.5 requires a peer of utf-8-validate@^5.0.2 but none is installed. You must install peer dependencies yourself.
npm WARN node-fetch@2.6.7 requires a peer of encoding@^0.1.0 but none is installed. You must install peer dependencies yourself.
npm WARN exb-server@0.1.0 No description
npm WARN exb-server@0.1.0 No repository field.
npm WARN exb-server@0.1.0 No license field.

### When building "client" I get these warnings

npm WARN @apideck/better-ajv-errors@0.3.2 requires a peer of ajv@>=8 but none is installed. You must install peer dependencies yourself.
npm WARN @jest/core@27.3.0 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN @jest/reporters@27.3.0 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN acorn-import-assertions@1.8.0 requires a peer of acorn@^8 but none is installed. You must install peer dependencies yourself.
npm WARN airbnb-prop-types@2.16.0 requires a peer of react@^0.14 || ^15.0.0 || ^16.0.0-alpha but none is installed. You must install peer dependencies yourself.
npm WARN analytics-utils@1.0.4 requires a peer of @types/dlv@^1.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN bootstrap@4.6.0 requires a peer of jquery@1.9.1 - 3 but none is installed. You must install peer dependencies yourself.
npm WARN enzyme-adapter-react-16@1.15.6 requires a peer of react@^16.0.0-0 but none is installed. You must install peer dependencies yourself.
npm WARN enzyme-adapter-react-16@1.15.6 requires a peer of react-dom@^16.0.0-0 but none is installed. You must install peer dependencies yourself.
npm WARN react-test-renderer@16.14.0 requires a peer of react@^16.14.0 but none is installed. You must install peer dependencies yourself.
npm WARN enzyme-adapter-utils@1.14.0 requires a peer of react@0.13.x || 0.14.x || ^15.0.0-0 || ^16.0.0-0 but none is installed. You must install peer dependencies yourself.
npm WARN fork-ts-checker-webpack-plugin@6.3.4 requires a peer of vue-template-compiler@* but none is installed. You must install peer dependencies yourself.
npm WARN jest@27.3.0 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jest-cli@27.3.0 requires a peer of node-notifier@^8.0.1 || ^9.0.0 || ^10.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jest-config@27.3.0 requires a peer of ts-node@>=9.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN jsdom@16.7.0 requires a peer of canvas@^2.5.0 but none is installed. You must install peer dependencies yourself.
npm WARN react-custom-scrollbars@4.2.1 requires a peer of react@^0.14.0 || ^15.0.0 || ^16.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN react-custom-scrollbars@4.2.1 requires a peer of react-dom@^0.14.0 || ^15.0.0 || ^16.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN resolve-url-loader@4.0.0 requires a peer of rework@1.0.1 but none is installed. You must install peer dependencies yourself.
npm WARN resolve-url-loader@4.0.0 requires a peer of rework-visit@1.0.0 but none is installed. You must install peer dependencies yourself.
npm WARN terser@5.10.0 requires a peer of acorn@^8.5.0 but none is installed. You must install peer dependencies yourself.
npm WARN sass-loader@12.2.0 requires a peer of fibers@>= 3.1.0 but none is installed. You must install peer dependencies yourself.
npm WARN sass-loader@12.2.0 requires a peer of sass@^1.3.0 but none is installed. You must install peer dependencies yourself.
npm WARN ws@7.5.5 requires a peer of bufferutil@^4.0.1 but none is installed. You must install peer dependencies yourself.
npm WARN ws@7.5.5 requires a peer of utf-8-validate@^5.0.2 but none is installed. You must install peer dependencies yourself.
npm WARN node-fetch@2.6.7 requires a peer of encoding@^0.1.0 but none is installed. You must install peer dependencies yourself.
npm WARN exb-client@1.7.0 No description
npm WARN exb-client@1.7.0 No repository field.
npm WARN exb-client@1.7.0 No license field.


