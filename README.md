Use like host, but is keyed on IP eg

host6 { 'localhost-v4':
  ip => '127.0.0.1',
  hostname => 'localhost',
}

host6 { 'localhost-v6':
  ip => '::1', 
  hostname => 'localhost',
}

or 

host6 { '127.0.0.1':
  hostname => 'localhost',
} 

host6 { '::1':
  hostname => 'localhost',
}        
