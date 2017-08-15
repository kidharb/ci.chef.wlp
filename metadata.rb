name             'was_liberty'
maintainer       'Kidhar Bachan'
maintainer_email ''
license          'All Rights Reserved'
description      'Installs WebSphere Application Server Liberty Profile'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.2'

supports "aix"
supports "debian"
supports "ubuntu"
supports "centos"
supports "redhat"

depends "java", ">= 1.16.4"
