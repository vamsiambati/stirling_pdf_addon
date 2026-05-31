# Use the frooodle/s-pdf image as the base
FROM frooodle/s-pdf:latest-fat

# Install Tini to manage processes (base image is Debian/Ubuntu, not Alpine)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends tini \
	&& rm -rf /var/lib/apt/lists/*

# Copy and make the run.sh script executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Use Tini as the entrypoint to handle processes
ENTRYPOINT ["tini", "--"]

# Run Stirling-PDF through the copied run.sh script
CMD ["/run.sh"]
