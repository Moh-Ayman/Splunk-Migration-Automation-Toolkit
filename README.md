# Splunk Migration Automation Toolkit
Splunk Migration Automation Toolkit provides Users Listing, Comparison and Creation User Deletion&Creation Splunk CMDs.

Usage: ./.../Service-Integration-New.sh [OPTION]...
	"Options:
	RMARK: Options Order Is Mandatory 
	--function=usernames [role name] 			  .. To Return All usernames for specific role to $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt
	--function=runall [role name] 			  .. To Return All usernames for specific role to $SCRIPT_CURRENT_DIRECTORY/usernames_env1.txt
	--function=compare        			          .. To Return Users To Be Created & Edited $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt & toBeEdited.txt
	--function=tobecreated NOT Available                  	  .. To Return Users To Be Created $SCRIPT_CURRENT_DIRECTORY/toBeCreated.txt
	--function=allusersaddcmd [role name] 		          .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env1.txt
	--function=tobeedited  NOT Available           		     .. To Return Users To Be Edited $SCRIPT_CURRENT_DIRECTORY/toBeEdited.txt
	--function=genaddcmd  [\"-role role name -role role name\"]  .. To Return Script To Create Users $SCRIPT_CURRENT_DIRECTORY/createCMD.txt
	--function=geneditcmd [\"-role role name -role role name\"]  .. To Return Script To Edit Users $SCRIPT_CURRENT_DIRECTORY/editCMD.txt"

  	--function=runall  .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt
	--function=allusersaddcmd  .. To Return All users add cmd $SCRIPT_CURRENT_DIRECTORY/allusersaddcmd_env2.txt
	--function=usernames       .. To Return all usernames $SCRIPT_CURRENT_DIRECTORY/usernames_env2.txt"