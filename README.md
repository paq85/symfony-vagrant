# Vagrant for Symfony Standard Edition Project

This project will help you create a Vagrant managed Virtual Machine for developing Symfony Framework based projects
 
## Requirements

- Vagrant
- VirtualBox

## Setup

## Setup Hosts

Edit /etc/hosts so you can access created VM by symfony.dev domain.
Add following line:

    192.168.33.10 symfony.dev

## Run Vagrant

    vagrant up
 
Validate Apache and PHP works properly by opening [PHP Info](http://symfony.dev/phpinfo.php)
 
## Setup new Symfony Standard Edition Project

Log in to VM and run

    cd /vagrant/projects
    symfony new symfony_project
    ln -s /vagrant/projects/symfony_project/web /vagrant/web/symfony_project
    
Newly created symfony project is now in `symfony_project` folder.
It should be available via web browser at [Symfony App Example](http://symfony.dev/symfony_project/app/example)

Some small adjustments are needed:

Edit symfony_project/app/console

- Uncomment `umask(0000);`

Edit symfony_project/web/app_dev.php

- Uncomment `umask(0000);`
- Change allowed IP address to 192.168.33.1 `array('127.0.0.1', 'fe80::1', '::1', '192.168.33.1')`
    
Symfony project should be available [HERE](http://symfony.dev/symfony_project/) - eg. [Example Page](http://symfony.dev/symfony_project/app/example)

Enjoy developing your Symfony based project :)

## Performance Optimization

- Consider using [Vagrant Cachier](http://fgrehm.viewdocs.io/vagrant-cachier/usage) plugin
`vagrant plugin install vagrant-cachier`
- Consider using [vagrant-winnfsd](https://github.com/GM-Alex/vagrant-winnfsd)
`vagrant plugin install vagrant-winnfsd`
- Consider moving Symfony cache and logs to VM's folder

# Credits
[nater1067/Vagrant-Symfony-2](https://github.com/nater1067/Vagrant-Symfony-2) and other scripts and articles found on the web