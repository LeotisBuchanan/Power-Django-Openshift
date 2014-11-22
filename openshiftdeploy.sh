#!/bin/sh
#author : Girish Joshi <girish946@gmail.com>

#create a new Application on Rhcloud. 
rhc app create $1 python-2.7 

#add mysql cartridge to the project.
rhc add-cartridge mysql-5.5 --app $1

#create a new Django project.
cd $1
django-admin startproject $1

#make it's directory structure right for openshift.
cd $1
mv manage.py ../manage.py
mv $1/* ./
rm -rf $1
cd .. 	

#start a new Django-app.
django-admin startapp $1"app"

#these directries are required by Openshift.
mkdir static
echo "put your static files here." >> static/Readme.md 

mkdir wsgi
mkdir wsgi/static
echo "this is just a dummy file" >> wsgi/static/Readme.md

#writing requirements in the requirements.txt
echo "django >= 1.7, < 1.8" >> requirements.txt


#writing action_hooks scripts.
cd .openshift/action_hooks/

echo "#!/bin/bash
# This is a simple build script and will be executed on your CI system if
# available. Otherwise it will execute while your\napplication is stopped
# before the deploy step. This script gets executed directly, so it
# could be python, php, ruby, etc.
# Activate VirtualEnv in order to use the correct libraries
echo \"--> ACTION HOOK: build <--\"" >> build

echo "#!/bin/bash
# This is a simple build script and will be executed on your CI system if
# available. Otherwise it will execute while your\napplication is stopped
# before the deploy step. This script gets executed directly, so it
# could be python, php, ruby, etc.
# Activate VirtualEnv in order to use the correct libraries
echo \"--> ACTION HOOK:  pre_build  <--\"" >> pre_build

echo "#!/bin/bash
# This is a simple build script and will be executed on your CI system if
# available. Otherwise it will execute while your application is stopped
# before the deploy step. This script gets executed directly, so it
# could be python, php, ruby, etc.
# Activate\nVirtualEnv in order to use the correct libraries\necho \"--> ACTION HOOK:  post_deploy  <--\"" >> post_deploy

echo "#!/bin/bash 
# This deploy hook gets executed after dependencies are resolved and the 
# build hook has beenn run but before the application has been started back
# up again. This script gets executed directly, so it could be python, php,
# ruby, etc.

echo \"---> ACTION HOOK: deploy <---\"
source \$OPENSHIFT_HOMEDIR/python/virtenv/bin/activate

echo \"Executing 'python $OPENSHIFT_REPO_DIR/manage.py migrate --noinput'\"
python \"\$OPENSHIFT_REPO_DIR\"/manage.py migrate --noinput 

echo \"Executing 'python $OPENSHIFT_REPO_DIR/manage.py collectstatic --noinput'\"
python \"\$OPENSHIFT_REPO_DIR\"/manage.py collectstatic --noinput" >> deploy


#grant execute permissions to action_hooks.
chmod +x build 
chmod +x pre_build 
chmod +x post_deploy 
chmod +x deploy 
cd ../..

echo $pwd

#make the default wsgi.py right.
echo "#!/usr/bin/python
import os

virtenv = os.environ['OPENSHIFT_PYTHON_DIR'] + '/virtenv/'
virtualenv = os.path.join(virtenv, 'bin/activate_this.py')
try:
    execfile(virtualenv, dict(__file__=virtualenv))
except IOError:
    pass
from $1.wsgi import application

#
# Below for testing only
#
if __name__ == '__main__':
    from wsgiref.simple_server import make_server
    httpd = make_server('localhost', 8051, application)
    # Wait for a single request, serve it and quit.
    httpd.handle_request()
" > wsgi.py 

echo `pwd`
cd ..

#make the proper settings in settings.py of your project.
python set_settings.py $1/$1/settings.py $1 >> settings.py
rm $1/$1/settings.py
mv settings.py $1/$1/settings.py
echo "bootstrapping done
      kindly now you can make the proper settings in $1/settings.py and your application is ready for deployment on openshift."
cd $1

#git push the project to the openshift.
git add --all 
git commit -m "initial commit"
git push origin 

