#!/bin/bash

SCRIPT_CURRENT_DIRECTORY="`dirname \"$0\"`"


search() {
	/opt/SP/splunk/bin/splunk search "$1" -maxout 100000
}

allusersaddcmd(){
	search '| rest /services/authentication/users | rename title AS username roles AS role | mvexpand role | search role=* | fields realname username role email | stats values(role) AS Roles by realname,email,username | eval Roles=mvjoin(Roles,"-role ") | eval roles_command="-role ".Roles |eval user_add_command="./splunk add user ".username." -password goblygook -email ".email." -full-name \"".realname. "\" ".roles_command | table user_add_command' | tail -n +3 - > $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt

sed -i 's/-role/ -role/g' allusersaddcmd_env2.txt
	
} 

usernames() {
	cut -f4 -d" " $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt
} > $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt

if [[ "$1" = "--function=allusersaddcmd" ]] ||  [[ "$1" = "--function=usernames" ]] ||  [[ "$1" = "--function=runall" ]]
then
	if [[ "$1" = "--function=allusersaddcmd" ]]
	then
		echo "Returning  All users add cmd"
		allusersaddcmd 
		echo "[Success] Adding Command for all users Returned To $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt"
	elif [[ "$1" = "--function=usernames" ]]
	then
		echo "Returning  All Env2 user names"
                usernames
                echo "[Success] All usernames Env2 To $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt"
	elif [[ "$1" = "--function=runall" ]]
	then
		echo "Returning  All Env2 user names"
                allusersaddcmd
		usernames
                echo "[Success] All usernames Env2 To $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt"
	fi
else
	echo "Usage: ./.../Service-Integration-New.sh [OPTION]... "
	echo "Options:
	RMARK: Options Order Is Mandatory 
	--function=runall  .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt
	--function=allusersaddcmd  .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt
	--function=usernames       .. To Return all usernames $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt"
	
fi
