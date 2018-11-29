#!/bin/bash
package-cleanup -y --oldkernels --count=1
yum -q updateinfo list > temp_yum

hostname=$(echo ${HOSTNAME,,} | sed 's/\.RXID.*//')
output='available_updates_'$hostname'_'$(date +%F)'.csv'
echo -e '"Available packages updates for server '$hostname' as of '`date +%F`'"\n\n' > $output
# yum -q updateinfo summary | while read u
# do
#         if [[ ! -z "$u" ]]
#         then
#                 echo \"$u\" >> $output
#         fi
# done
echo -e '\n\n"Package name","Architecture","Installed version","Update version","Advisory","Update type"' >> $output
yum -q check-update| while read i
do
        if [[ ! -z "$i" ]]
        then
                [[ $i == "Obsoleting Packages" ]] && break
                newver=$(echo $i | awk '{print $2}')
                packname=${i%%\ *}
                architecure=$(echo $i | sed 's/[^.]*\.//;s/ .*$//')
                advisory=$(grep -m1 "${packname%%.*}-$newver" temp_yum | awk '{print "\"" $1 "\",\"" $2 "\""}')
                echo $(rpm -q "$packname" --qf '"%{n}","%{arch}","%{v}-%{r}","')${newver##*:}'",'$advisory >> $output
        fi
done
