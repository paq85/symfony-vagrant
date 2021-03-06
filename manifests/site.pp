# Install our dependencies

exec {"apt-get update":
  path => "/usr/bin",
}

package {"apache2":
  ensure => present,
  require => Exec["apt-get update"],
}

service { "apache2":
  ensure => "running",
  require => Package["apache2"]
}

package {['openssh-server', 'mysql-server', 'mysql-client', 'mc', 'htop', 'sysstat', 'jnettop', 'git', 'curl']:
  ensure => installed,
  require => Exec["apt-get update"]
}

service { 'mysql':
  ensure  => running,
  require => Package['mysql-server'],
}

package { 'php5-cli':
  ensure => installed
} ->
exec { 'php_cli_config':
  command => '/bin/sed -i "s/^;date.timezone =/date.timezone = \'Europe\/Warsaw\'/g" /etc/php5/cli/php.ini',
  creates => '/etc/php5/cli/php.ini'
}

package { 'libapache2-mod-php5' :
  ensure => installed
} ->
exec { 'php_apache2_config':
  command => '/bin/sed -i "s/^;date.timezone =/date.timezone = \'Europe\/Warsaw\'/g" /etc/php5/apache2/php.ini',
  creates => '/etc/apache2/cli/php.ini'
}

package { ["php5-common", "php5-mysql", "php5-curl", "php5-apcu", "php5-sqlite", "php5-gd", "php5-imagick", "php5-intl", "php5-xsl", "php5-mcrypt", "libssh2-php"]:
  ensure => installed,
  notify => Service["apache2"],
  require => [Exec["apt-get update"], Package['mysql-client'], Package['apache2']],
}

exec { "/usr/sbin/a2enmod rewrite" :
  unless => "/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load",
  notify => Service[apache2],
  require => Package['apache2']
}

# Set up a new VirtualHost

file {"/var/www":
  ensure => "link",
  target => "/vagrant/web",
  require => Package["apache2"],
  notify => Service["apache2"],
  replace => yes,
  force => true,
}

file { "/etc/apache2/sites-available/000-default.conf":
  ensure => "link",
  target => "/vagrant/manifests/assets/vhost.conf",
  require => Package["apache2"],
  notify => Service["apache2"],
  replace => yes,
  force => true,
}

# Set Apache to run as the Vagrant user

exec { "ApacheUserChange" :
  command => "/bin/sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars",
  onlyif  => "/bin/grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars",
  require => Package["apache2"],
  notify  => Service["apache2"],
}

exec { "ApacheGroupChange" :
  command => "/bin/sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars",
  onlyif  => "/bin/grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars",
  require => Package["apache2"],
  notify  => Service["apache2"],
}

exec { "apache_lockfile_permissions" :
  command => "/bin/chown -R vagrant:www-data /var/lock/apache2",
  require => Package["apache2"],
  notify  => Service["apache2"],
}

# Composer
exec { "composer" :
  command => "/usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php && mv composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer",
  creates => '/usr/local/bin/composer',
  require => Package['php5-cli']
}

# Phing
exec { "phing" :
  command => "/usr/bin/curl -Ss -o phing.phar http://www.phing.info/get/phing-latest.phar && mv phing.phar /usr/local/bin/phing && chmod a+x /usr/local/bin/phing",
  creates => "/usr/local/bin/phing",
  require => Package['php5-cli']
}

# Symfony
exec { "symfony_installer" :
  command => "/usr/bin/curl -LsS http://symfony.com/installer > symfony.phar && mv symfony.phar /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony && symfony",
  creates => '/usr/local/bin/symfony',
  require => Package['php5-cli']
}

