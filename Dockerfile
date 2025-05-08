# Use Alpine as the base image
FROM alpine:3.18

# Set environment variables for Java and Maven versions
ENV JAVA_VERSION=17.0.8 \
    MAVEN_VERSION=3.9.5 \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk \
    MAVEN_HOME=/opt/maven \
    PATH=$MAVEN_HOME/bin:$PATH

# Create a group and user for running the application
RUN addgroup -g 1000 maven \
    && adduser -u 1000 -G maven -s /bin/sh -D maven \
    # Install required dependencies and tools
    && apk add --no-cache \
        openjdk17-jdk \
        bash \
        curl \
        tar \
        git \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gnupg \
    # Install Maven
    && curl -fsSL "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" -o /tmp/apache-maven.tar.gz \
    && curl -fsSL "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz.sha512" -o /tmp/maven.sha512 \
    && echo "$(cat /tmp/maven.sha512)  /tmp/apache-maven.tar.gz" | sha512sum -c - \
    && mkdir -p /opt/maven \
    && tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz /tmp/maven.sha512 \
    # Cleanup unnecessary packages
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

# Ensure the script is executable
RUN ls -l /usr/local/bin/ && chmod +x /usr/local/bin/docker-entrypoint.sh

# Set user permissions
USER maven

# Smoke tests to verify installations
RUN java -version && mvn -version

# Set the entry point for the container
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command to run if none is specified
CMD ["mvn", "--version"]
