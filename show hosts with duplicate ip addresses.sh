#Display hosts with duplicate IP addresses (ignoring lines with HSRP in them)
awk -F' ' '{print $1}' hosts |sort|uniq -d|grep -F -f - hosts | grep -v HSRP
