# Stage 1: Build (Let Kamal handle the arch via deploy.yml)
FROM alpine:latest AS builder

RUN apk add --no-cache zip curl

WORKDIR /build

# Download Redbean 3.0.0
# We use the generic .com APE binary
RUN curl -k -o redbean.com https://redbean.dev/redbean-3.0.0.com && \
    chmod 755 redbean.com

COPY docs/ .
COPY .init.lua .

# Zip the content into the executable
RUN zip -r redbean.com . -x redbean.com

# Stage 2: Runtime
FROM alpine:latest

# Copy the final executable
COPY --from=builder /build/redbean.com /server

# Make sure it's executable
RUN chmod 755 /server

# Match the port in your deploy.yml
EXPOSE 5010

# THE FIX: Run with 'sh' to trigger the APE self-extractor
# We also bind the port explicitly
CMD ["/bin/sh", "/server", "-p", "5010"]