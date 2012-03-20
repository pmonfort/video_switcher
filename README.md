Requirements
============

- MySql server
- Either Apache or nginx for production mode

Installation Notes
==================

- Install ruby version 1.9.2
- Install rubygems
- Install some basic gems:
    $ gem install bundler
    $ gem install passenger

- Install the apache2 module:
    $ passenger-install-apache2-module
  or the nginx module:
    $ passenger-install-nginx-module

- Follow *passenger* directions, you may need to install additional system libraries,
  the installer will let you know about that

- Create a database for your app:
    $ mysqladmin create my_db

- Uncompress your application file to some directory and go there:
    $ cd <code_directory>
  If you used RVM to install ruby a warning will show up, say *yes* here or say no and remove the rvmrc file:
    $ rm .rvmrc

- Copy the sample settings file:
    $ cp settings.yml.sample settings.yml
  And edit the new file with your database creadentials including the databse name that you created earlier

- Run bunlder:
    $ bundle install

- Configure Apache (similar for nginx) by creating a virtual host pointing to the *public* directory of your app:
  in apache httpd.conf or sites-enabled file:

    <VirtualHost *:80>
      ServerName www.yourapplication.com
      DocumentRoot /path/to/app/public
      <Directory /path/to/app/public>
        Allow from all
        Options -MultiViews
      </Directory>
    </VirtualHost>

- You can also test your application with rack only, on port 4567 for example, if you want:
    $ cd /path/to/app
    $ export RACK_ENV=production
    $ bundle install
    $ rackup -p 4567

