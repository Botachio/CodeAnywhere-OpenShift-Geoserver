# CodeAnywhere-OpenShift
Trying to automate setting up OpenShift Tools on CodeAnywhere 

## Usage
Open CodeAnywhere Editor[1] and create a new connection:
File > New Connection > GitHub

In the dialog choose **this** repository and click NEXT.
In the next dialog choose a Ruby stack and click CREATE.

It may be possible to let CodeAnywhere choose the correct stack automatically...

Start the setup script using ``./setup`` in the default working directory.
After installing the ``rhc`` Ruby gem this starts ``rhc setup``.

- Enter server hostname (if not default).
- Enter OpenShift username (email).
- Enter OpenShift password.
- Answer ``yes`` to create token.

This process should end with ``Your client tools are now configured``.

[1] http://codeanywhere.com/editor
