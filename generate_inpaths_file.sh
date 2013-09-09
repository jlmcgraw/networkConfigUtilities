# tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
ls -tQ ./configuration_files/Steelheads/*| xargs tac | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
