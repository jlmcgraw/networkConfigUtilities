# Create host file from lumped config file, sorted by IP address
./generate_hosts_files.sh | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | uniq > hosts_sorted.txt 
