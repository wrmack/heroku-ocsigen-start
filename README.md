# heroku-ocsigen-start

This is a Dockerfile for deploying the Ocaml [Ocsigen-start](http://ocsigen.org/ocsigen-start/2.2/manual/intro) application to Heroku as a Docker container.  

It includes the eliom web framework.  Image size is 2.93GB.

**Please see [heroku-ocsigen-start-thin](https://github.com/wrmack/heroku-ocsigen-start-thin/tree/master) for a Dockerfile which creates an image of only 519MB and which loads much quicker in Heroku.**

## Assumptions
- you have a Heroku plan
- you have Docker installed

## Prelude
- The Dockerfile copies over to the docker image your website and configuration files.
- I have included the very basic site setup produced by locally running `eliom-distillery -name *yoursitename*`
- the Dockerfile script runs the container command `make test.byte` which uses options in `Makefile.options`
- I have created the file `Makefile.options.template` to hold variables for ${PORT}, ${USER}, ${GROUP} and ${PREFIX}
- these variables are set by Heroku (PORT) and by the `entrypoint.sh` script which then writes `Makefile.options.template` to `Makefile.options`


## To deploy to Heroku

#### Create a Heroku app
```
cd to directory with this Dockerfile
heroku login
heroku container:login
heroku create *your-app-name*
```
#### Each time you make changes, push to Heroku and release
```

heroku container:push web --app *your-app-name*
heroku container:release web --app *your-app-name*
```
#### View on web
```
heroku open --app *your-app-name*
```

#### Inspect running Heroku app
- run a bash shell in the container
```
heroku run bash --app *your-app-name*
```
- view logs
```
heroku logs --tail --app *your-app-name*
```

## To test locally

- uncomment PORT, USER, GROUP, PREFIX variables in entrypoint.sh for local use and comment out the Heroku ones, then
```
docker build -t *your-image-name*
docker run -it -d --name *your-container-name* -p 8080:8080 *your-image-name*
```
- view on localhost:8080


Live site [here](https://wrmack-ocsi-start.herokuapp.com).  I am using the free tier so it takes a while to wake up a dyno if it is sleeping.



