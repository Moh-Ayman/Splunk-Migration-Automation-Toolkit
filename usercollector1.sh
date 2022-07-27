#!/bin/bash

SCRIPT_CURRENT_DIRECTORY="`dirname \"$0\"`"

role=$2

search() {
	/opt/SP/splunk/bin/splunk search "$1" -maxout 100000
}


allusersaddcmd(){
        search '| rest /services/authentication/users | rename title AS username roles AS role | mvexpand role | search role=*'$role'* | fields realname username role email | stats values(role) AS Roles by realname,email,username | eval Roles=mvjoin(Roles,"-role ") | eval roles_command=" -role ".Roles |eval user_add_command="./splunk add user ".username." -password goblygook -email ".email." -full-name \"".realname. "\"  " .roles_command | table user_add_command' | tail -n +3 - > $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt

sed -i 's/-role/ -role/g' allusersaddcmd_env1.txt

}


usernames(){
	 cut -f4 -d" " $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt
} > $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt

comp() {
	grep -wf usernames_env1.txt usernames_env2.txt > $SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt
	grep -vwf toBeEdited.txt usernames_env1.txt > $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt
}

comptobecreated() {

	diff -y --suppress-common-line $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt | cut -f1 -d" " | sed '/^\s*$/d'

} > $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt

comptobeedited() {
	grep -wf usernames_env1.txt usernames_env2.txt
} > $SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt


genaddcmd() {
	input="$SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt"
	while read  var
	do
		#URole=`grep -w "$var" $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt |cut -f11- -d" "`
		grep "$var" $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt | tr -s '[:space:]' 
	done < $input >> createCMD.sh
	sed -i 's/app_gasf/app_read_'$role' -role opsuser_'$role'/g' createCMD.sh
} 
geneditcmd() {
	input="$SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt"
	while read  var
	do

		grep -w "$var" $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt |cut -f11- -d" " >  $SCRIPT_CURRENT_DIRECTORY/env2_role
		cat env2_role
		sed -ie 's/.*"/ /g' $SCRIPT_CURRENT_DIRECTORY/env2_role
		sed -e 's/.*"/ /g' env2_role
		
		echo "`grep -w "$var" $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt` `cat $SCRIPT_CURRENT_DIRECTORY/env2_role`" | tr -s '[:space:]' >> editCMD.sh
		#sed -i 's/*\"/" "/g' editCMD.sh
		sed -i 's/app_gasf/app_read_'$role' -role opsuser_'$role'/g'  $SCRIPT_CURRENT_DIRECTORY/editCMD.sh
		sed -i 's/add/edit/g'  $SCRIPT_CURRENT_DIRECTORY/editCMD.sh
		#echo "$G $3" >> editCMD.sh
	done < "$input"
	input="$SCRIPT_CURRENT_DIRECTORY/editCMD.sh"
} 

if [[ "$1" = "--function=allusersaddcmd" ]] || [[ "$1" = "--function=usernames" ]] || [[ "$1" = "--function=tobecreated" ]] || [[ "$1" = "--function=tobeedited" ]] || [[ "$1" = "--function=genaddcmd" ]] || [[ "$1" = "--function=geneditcmd" ]] || [[ "$1" = "--function=compare" ]] || [[ "$1" = "--function=runall" ]]
then
	if [[ "$1" = "--function=usernames" ]]
	then
		echo "Returning Username for role $role"
		usernames 
		echo "[Success] Usernames Returned To $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt"
	elif [[ "$1" = "--function=runall" ]]
	then
		echo "Returning  All users add & edit cmd"
                allusersaddcmd
		usernames
		comp
		genaddcmd
		geneditcmd
                echo "[Success] Adding Command for all users Returned To $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt"
	elif [[ "$1" = "--function=compare" ]]
	then
		echo "Returning  All users add & edit cmd"
                comp
                echo "[Success] Adding Command for all users Returned To $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt"
	elif [[ "$1" = "--function=allusersaddcmd" ]]
	then
		echo "Returning  All users add cmd"
                allusersaddcmd
                echo "[Success] Adding Command for all users Returned To $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt"
	#elif [[ "$1" = "--function=tobecreated" ]]
	#then
	#	echo "Returning Users To Be Created"
        #        comptobecreated
        #        echo "[Success] Users Returned To $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt"
	#elif [[ "$1" = "--function=tobeedited" ]]
        #then
        #        echo "Returning Users To Be Edited"
        #        comptobeedited
        #        echo "[Success] Users Returned To $SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt"
	elif [[ "$1" = "--function=genaddcmd" ]]
        then
                echo "Returning Script To Create Users"
                genaddcmd
                echo "[Success] Script Created $SCRIPT_CURRENT_DIRECTORY/createCMD.txt"
	elif [[ "$1" = "--function=geneditcmd" ]]
        then
                echo "Returning Script To Edit Users"
		echo $3
                geneditcmd
                echo "[Success] Script Edit $SCRIPT_CURRENT_DIRECTORY/editCMD.txt"

	fi
else
	echo "Usage: ./.../Service-Integration-New.sh [OPTION]... "
	echo "Options:
	RMARK: Options Order Is Mandatory 
	--function=usernames [role name] 			  .. To Return All usernames for specific role to $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt
	--function=runall [role name] 			  .. To Return All usernames for specific role to $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt
	--function=compare        			          .. To Return Users To Be Created & Edited $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt & toBeEdited.txt
	--function=tobecreated NOT Available                  	  .. To Return Users To Be Created $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt
	--function=allusersaddcmd [role name] 		          .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt
	--function=tobeedited  NOT Available           		     .. To Return Users To Be Edited $SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt
	--function=genaddcmd  [\"-role role name -role role name\"]  .. To Return Script To Create Users $SCRIPT_CURRENT_DIRECTORY/createCMD.txt
	--function=geneditcmd [\"-role role name -role role name\"]  .. To Return Script To Edit Users $SCRIPT_CURRENT_DIRECTORY/editCMD.txt"
	
fi
