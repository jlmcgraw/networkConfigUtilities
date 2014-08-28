l    #!/usr/bin/perl

  #
  # takes output from a Solarwinds Orion NCM command script
  # that runs "show ip interface brief | exclude unassigned"
  # and produces a "hostname IP" output for import into DNS
  # this makes traceroutes more readable
  #
  # usage: ./interface2dns.pl < inputfile.txt
  # inputfile.txt will look like this
  # when produced by Orion NCM 6.x:
  #
  # routerA.test.com  (10.38.16.126)
  # Interface   IP-Address      OK? Method Status Protocol
  # Loopback0   172.29.255.1    YES NVRAM  up     up
  # Vlan163     10.38.16.126    YES NVRAM  up     up
  # Vlan165     10.38.16.117    YES NVRAM  up     up
  #
  #
  while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "#" character
    if ( $_ =~ /\#/ ) {

        # split that line on the # character
        @hostnameFields = split /\#/, $_;

        # hostname is the first element before the first .
        $hostname = uc $hostnameFields[0];

    }

    # identify lines with "up" in them to remove garbage
    if ( $_ =~ /up\/up/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        $fields[0] =~ s/\/|:/-/g;

        #print in "ipaddr hostname-interface" format
        $int_name = $fields[0];
    }

    if ( $_ =~
        /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/
      )
    {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;
        $ipv6_addr = $fields[1];
        print "$ipv6_addr\t\t$hostname-$int_name\n";
    }

}
