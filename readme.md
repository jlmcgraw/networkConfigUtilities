create_host_files
================
This is a collection of perl scripts to pull information from the configuration files of various network devices (eg. Cisco routers and switches, Riverbed Steelheads, Cisco Nexus, Cisco ASA) and use it to create various outputs (eg. a hosts file with all Layer 3 interfaces in it, indicating which ones pass through a steelhead)

	organize_configuration_files.sh
		Given a bunch of configuration files in the "configuration_files" directory is attempts to guess what they type of device they are for and move them to the appropriate subdirectory

	generate_hosts_file.sh
		Given configs in the appropriate hardcoded subdirectories (see "Organize_Configuration_Files.sh") this calls the perl scripts to generate host information from them

	generate_hosts_file_sorted.sh
		Calls "generate_hosts_file.sh" and sorts by IP address

	inpath-interfaces-and-subnets-from-steelhead.pl
		Generates the input file for "add_inpath_to_hosts.pl" from Steelhead configuration files
	 	usage: tac ./Configuration_Files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt

	add_inpath_to_hosts.pl
		Matches INPATH interface subnets with IP addresses from a hosts file and appends Steelhead name

	generate_bgp_neighbor_data.pl
		Takes some output from various show commands from routers and creates a table of BGP information to be fed into generate-asn-graph.pl

	generate-asn-graph.pl
		Takes the input of generate_bgp_neighbor_data.pl and uses graphviz to create a picture (kinda sorta)

Getting started
---------------

make destination<br>
make clean<br>
Put all of your configuration files into "configuration_files"<br>
make organize<br>
make inpath<br>
make hosts<br>
make hostsWithInpath<br>
make combine<br>

