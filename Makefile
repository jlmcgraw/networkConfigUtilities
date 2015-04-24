all: clean destination organize inpath hosts hostWithInpath combine

destination:
	#Make sure the directory structure for the config files exists
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
	-mkdir ./configuration_files/ACME

clean:
	#Clean out the configuration directories so no old information is kept
	find ./configuration_files/ -name "*" -type f -exec rm {} \;
	rm ./inpaths.txt ./hosts.txt ./hostsWithInpath.txt ./hosts

organize:
	#After you've put all of your configuration files in the "configuration_files" directory this will organize them
	./organize_configuration_files.sh

inpath:
	#Get the inpath interfaces from Steelhead configs
	tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt

hosts:
	#create the base hosts file
	./generate_hosts_file.sh > hosts.txt

hostsWithInpath:
	#Match up entries in the hosts.txt file with inpath subnets from Steelhead configs
	./add_inpath_to_hosts.pl -hhosts.txt -iinpaths.txt > hostsWithInpath.txt

combine:
	#Combine into the final hosts file 
	cat hostsWithInpath.txt hosts.txt > hosts

networks:
	#A list of network statements in configs.  Generally equal to advertised networks but not always
	./generate_advertised_networks.sh > networks.csv