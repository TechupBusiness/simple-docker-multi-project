# Single server multi project setup
This project is a **lightweight** fully featured multi-project architecture using docker, 
completely configurable by just one `.env` file per project. 

It is serving all projects via a reverse-proxy (traefik) on multiple domains (automatic SSL).
Docker knowledge is not required to get started, all services can be configured in a single `.env` file.
If you do have Docker knowledge, new services can be added and existing services can be easily extended. 
Pull requests (especially for new services) are welcome! 

The "shipped" system services are mostly using official repositories, this way projects based on this setup
will be always up-to-date, even if there is no update in this project. It's just an architecture "helper", not an application.

Get started by executing (requires Docker & docker-compose):
```
git clone REPO && cd simple-docker-multi-project && ./install.sh
```
This will guide you through the most basic settings and will start the reverse-proxy, which is the central
heart of this multi-project setup. Behind the scenes it's creating an `.env` based on your input for the 
reverse-proxy and then starting the traefik docker-container.

Next step is to add a project by executing:
```
./project.sh
```
This will guide you through the creation of a new project, allowing you to choose all needed services do all settings.
Behind the scenes it will simply bake together an `.env` file. And depending on the service it may do some additional work (e.g. generating a Dockerfile or creating needed folders for your content and backups).

**NOTE:** even though there are a few bash-scripts and lots of folder, the architecture is simple, straight forward and there a just a few conventions you need
to be aware of if you want to add you own services or modify existing ones.

## What is this project actually doing for real?
1. It is only using existing standard functionality of docker (container software) and docker-compose (=YAML file format processor to run docker container)
1. It ships a set of useful docker-compose files (=predefined services) that can be configured by using an `.env` file
1. It ships a pre-defined flexible default folder structure
1. It is wrapping the command-line (in a bash script) to make it easier for you to run these composed services together as an application
1. It offers an interactive and guided creation for `.env` files (e.g. input-helper, descriptions, ...)

You could still do anything manually, or simply use the help of this architecture.
