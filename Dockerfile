# syntax=docker/dockerfile:1.2
# Use small container image base
FROM nginx:1.23.3-alpine

# Install Python3.9
COPY --from=python:3.9-alpine3.16 /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python:3.9-alpine3.16 /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=python:3.9-alpine3.16 /usr/local/lib/libpython3.9.so.1.0 /usr/local/lib/libpython3.9.so.1.0
COPY --from=python:3.9-alpine3.16 /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so

# Set environment variables
ENV fileShare=/fileshare/
ENV mountPoint=/mnt/

# Store port from argument
ARG defaultPort=443
ENV serverPort=${defaultPort}

# Expose the port for access
EXPOSE ${serverPort}/tcp

# Setup for mounting
RUN apk add cifs-utils
RUN mkdir -p ${mountPoint}

# Copy Python scripts
COPY FSMount.py /
COPY NGINXServer.py /

# Setup NGINX default server configuration
RUN echo 'server { listen ' > /etc/nginx/conf.d/default.conf
RUN echo ${serverPort} >> /etc/nginx/conf.d/default.conf
RUN echo '; root ' >> /etc/nginx/conf.d/default.conf
RUN echo ${mountPoint} >> /etc/nginx/conf.d/default.conf
RUN echo '; location / { autoindex on; } }' >> /etc/nginx/conf.d/default.conf

# Copy the NGINX configuration for logs to send to DataDog
COPY nginx.conf /etc/nginx/nginx.conf

# Setup for cron jobs
RUN echo ' *  *  *  *  * echo Cron: Running minute jobs' >> /etc/crontabs/root
RUN echo ' *  *  *  *  * python3 -u /FSMount.py --fshare ${fileShare} --mpoint ${mountPoint}' >> /etc/crontabs/root
RUN echo ' *  *  *  *  * sleep 4; python3 -u /NGINXServer.py --port ${serverPort} --dir ${mountPoint}' >> /etc/crontabs/root

# Run single process
CMD ["/usr/sbin/crond", "-f"]
