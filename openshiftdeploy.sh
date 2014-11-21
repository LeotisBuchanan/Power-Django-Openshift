rhc app create $1 python-2.7 
rhc add-cartridge mysql-5.5 --app $1

cd $1
django-admin startproject $1

cd $1
mv manage.py ../manage.py
mv $1/* ./
rm -rf $1
cd .. 	

django-admin startapp $1"app"

mkdir static
echo "put your static files here." >> static/Readme.md 

mkdir wsgi
mkdir wsgi/static
echo "this is just a dummy file" >> wsgi/static/Readme.md

echo "django >= 1.7, < 1.8" >> requirements.txt

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

chmod +x build 
chmod +x pre_build 
chmod +x post_deploy 
chmod +x deploy 
cd ../..


echo "done"

#git add --all 
#git commit -m "initial commit"
#git push origin 

