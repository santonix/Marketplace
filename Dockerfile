# Use a newer version of Node.js as the builder stage
FROM node:20 as builder

# Set necessary environment variables, if any
ARG ENVIRONMENT
ENV CHROME_BIN=chromium

# Set the working directory inside the container to '/app'
WORKDIR /app

# Update and install Chromium
RUN apt-get update && apt-get install -y chromium

# Copy package-lock.json and package.json to the working directory
COPY package-lock.json package.json .

# Install npm dependencies and update Angular CLI globally
# Example Dockerfile snippet to install a specific version of Angular CLI
RUN npm uninstall -g @angular/cli && \
    npm cache clean --force && \
    npm install -g @angular/cli@17.0.0



# Copy the entire project directory into the container's working directory
COPY . .

# Build the Angular application using the specified environment
RUN ng build -c $ENVIRONMENT

# Use the NGINX base image for the production stage
FROM nginx:alpine

# Remove the contents of the default NGINX HTML directory
RUN rm -rf /usr/share/nginx/html/*

# Copy the built Angular application from the builder stage to the NGINX HTML directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 to allow external access
EXPOSE 80

# Command to start NGINX in the foreground when the container starts
CMD ["nginx", "-g", "daemon off;"]

