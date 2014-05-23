IPv4/IPv6 Hosts Module
======================


Usage
-----

Use like the resource host, but is keyed on IP eg

    host6 { 'localhost-v4':
      ip           => '127.0.0.1',
      hostname     => 'localhost.localdomain',
      host_aliases => ['localhost'],
    }

    host6 { 'localhost-v6':
      ip           => '::1', 
      hostname     => 'localhost.localdomain',
      host_aliases => ['localhost'],
    }

or 

    host6 { '127.0.0.1':
      hostname => 'localhost',
    }

    host6 { '::1':
      hostname => 'localhost',
    }


Notes
-----

This module is derived from the host resource from within puppet.
