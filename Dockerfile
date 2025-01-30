FROM meltano/meltano:v3.5.4

# Meltano project and install
COPY . /project/
RUN meltano install

# GitHub actions sets the working directory to the repo root when running.
# The entrypoint script sets the current directory to the meltano project and
# runs the container arguments as a command.
ENTRYPOINT ["./entrypoint.sh"]
