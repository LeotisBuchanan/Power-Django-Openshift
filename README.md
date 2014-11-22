Power-Django-Openshift
======================

*tool to bootstrapping a Django1.7 project on [Openshift](www.openshift.com).*

##useage

    $./openshiftdeploy.sh <Project-name>

###This Script 

    l. will create a new project on openshift.
    l. add mysql 5.5 cartridge in that project.
    l. create a new Django project in that directory.
    l. start a new app in Django project.
    l. make proper settings in wsgi.py and settings.py for Openshift.
    l. create the action_hooks to deploy project on openshift.


