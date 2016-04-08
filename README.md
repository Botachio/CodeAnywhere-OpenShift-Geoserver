# CodeAnywhere-OpenShift
Trying to automate setting up OpenShift on CodeAnywhere
and deploy Geoserver on OpenShift from there.

## Setup
Open CodeAnywhere Editor[1] and create a new connection:
File > New Connection > GitHub

In the dialog choose *this* repository and click NEXT.
In the next dialog choose a Ruby stack (I prefer the Ubuntu distro) and click CREATE.
It may be possible to let CodeAnywhere choose the correct stack automatically... This I have not tried.

The CodeAnywhere container is created. This may take a minute.
Right-click on the created container and open a SSH Terminal.

Start the setup script using ``./setup.sh`` in the default working directory (~/workspace).

After installing the ``rhc`` Ruby gem this starts ``rhc setup``:
- Enter server hostname (if not default).
- Enter OpenShift username (email).
- Enter OpenShift password.
- Answer ``yes`` to create token.
This process should end with ``Your client tools are now configured``.

At this point the CodeAnywhere Container is ready to create and manage OpenShift deployments.
The configured CodeAnywhere Container can be saved as a Custom Stack to ease future deployments.

[1] http://codeanywhere.com/editor

# Geoserver
Open CodeAnywhere Editor and connect to previously configured Container.
This can be one created using the instructions above, or from a Custom Stack with OpenShift client tools set up.

In the latter case *this* repository needs to be pulled from Github before continuing.
e.g. ``git remote add github <repository ssh connectstring>``

Start ``./app-create-geoserver.sh`` in the default working directory.
This performs the following actions: 

- Create a new OpenShift app for Geoserver.
- Disable Maven build on deployment by removing ``pom.xml`` from repository.
- Download and extract Geoserver webarchive (geoserver.war).
- Injects some OpenShift configuration files into the repository,
  . to move the Geoserver data directory to persistent storage on deployment, and
  . to configure Geoserver to use this new location on application start.
- Commits all these changes to the repository.
- Pushes the altered repository to OpenShift to initiate deployment.

**After deploying Geoserver it is important to go to the web interface,
log on using default credentials for the 'admin' account and change it's password!**

# PostGIS
Work in progress...
