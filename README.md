# NGINX Server

Docker files for container that runs a NGINX server using an Alpine base. Cron scheduler is used to run the necessary jobs in attempt to strive for uninterrupted service. 

## For running locally:

1. Clone or download this repository [Repository | GitLab](https://docs.gitlab.com/ee/user/project/repository/)

2. Install Docker Desktop [Docker Desktop | Docker](https://www.docker.com/products/docker-desktop/)

3. Open preferred terminal console (ex. CMD, GitBash, etc.)

4. Change directory to that which contains the Dockerfile

5. Build and run Docker image using:
   
   `docker build . -t nginx-server && docker run -d -p 443:443 --restart always --privileged --name nginx-server nginx-server`

## Additional online resources:

- [Cron jobs inside docker | Stack Overflow](https://stackoverflow.com/questions/72152000/how-to-perform-cron-jobs-every-5-minutes-inside-docker)
- [Start containers automatically | Docker Documentation](https://docs.docker.com/config/containers/start-containers-automatically/)
- [Docker run | Docker Documentation](https://docs.docker.com/engine/reference/commandline/run/)
