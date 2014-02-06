all: clean destination organize inpath hosts hostWithInpath combine

destination:
	-mkdir ./configuration_files/Steelheads
	-mkdir ./configuration_files/VPN
	-mkdir ./configuration_files/Extreme
	-mkdir ./configuration_files/ISG
	-mkdir ./configuration_files/IOS12
	-mkdir ./configuration_files/IOS15
	-mkdir ./configuration_files/GLX
	-mkdir ./configuration_files/F5
	-mkdir ./configuration_files/Nexus
	-mkdir ./configuration_files/ASA
	-mkdir ./configuration_files/FWSM
	-mkdir ./configuration_files/ACE

clean:
	find ./configuration_files/ -name "*" -type f -exec rm {} \;
	rm ./inpaths.txt ./hosts.txt ./hostsWithInpath.txt ./hosts

organize:
	./organize_configuration_files.sh

inpath:
	tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt

hosts:
	./generate_hosts_file.sh > hosts.txt

hostsWithInpath:
	./add_inpath_to_hosts.pl -hhosts.txt -iinpaths.txt > hostsWithInpath.txt

combine: 
	cat hostsWithInpath.txt hosts.txt > hosts
