#!/bin/bash

export TFE_TOKEN="<TFE_TOKEN>" #YOU NEED TO CREATE USER BASED TOKEN(Terraform Cloud WEBUI/User/settings/Tokens) OR CONFIG CREATION WILL FAIL
export TFE_ORG="<TFE-ORG>"
export TFE_ADDR="app.terraform.io"
export execdir="<SCRIPT-EXEC-DIR>"
export CURL_CMD="curl -ks"
export PATH=$PATH:$execdir

export REPO_API_TOKEN="<GITHUB_Personal Access Token>" 
export REPO_FID="<GITHUB_USER_ID>"

export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
export AWS_REGION="<AWS_REGION>"

initiateTempFolders(){
	repo=""	
	cd $execdir
	rm -rf $execdir/tempdir;mkdir $execdir/tempdir;mkdir $execdir/tempdir/temprepo;cd $execdir/tempdir/temprepo
	echo "In Github Repo"
	echo "Cloning Now"
	git clone -q https://${REPO_API_TOKEN}@github.com/${REPO_FID}/${appname}.git
	if [ $? -eq 0 ]; then
		echo "Config Cloned Successfully"	
		cp -R $execdir/tempdir/temprepo/$appname/* $execdir/tempdir/	
		rm -rf $execdir/tempdir/temprepo
		cp -R $execdir/variable.template.json $execdir/variableupdate.template.json $execdir/apply.json $execdir/workspace.template.json $execdir/configversion.json $execdir/run.template.json $execdir/tempdir
	fi
}



getTFVariableVal(){
	set -e
	workspace=$1
	key=$2
	category=$3
	#echo "workspace-->$workspace"
	#echo "key-->$key"
	#echo "category-->$category"
	varvalue=""
	check_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	#echo "check_workspace_result-->$check_workspace_result"
	if [[ $check_workspace_result != *"404"* ]] ; then
		workspace_id=$(echo $check_workspace_result | jq .[].id | sed 's/"//g')
		#echo "workspace_id-sss->$workspace_id"
		if [ ! -z "$workspace_id" ]; then
			list_variables_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
			#echo "list_variables_result-->$list_variables_result"
			varvalue=$(echo $list_variables_result | jq '.data[] |  select(.attributes.key == "'$key'") | select(.attributes.category == "'$category'") | .attributes.value'  | sed 's/"//g')	
			#echo "varvalue-->$varvalue"
		fi
	fi
	echo $varvalue	
}

updateTFVariables(){
	#key;value;<variable type: terraform or env>;<HCL true or false>;<sensitive: true or false>;description
	#aws_region;us-east-1;terraform;false;false;preferred region
	set -e
	workspace=$1
	key=$2
	value=$3
	value=$(echo "$value" |sed 's,/,\\/,g')
	category=$4
	hcl=$5
	sensitive=$6
	description=$7
	varid=""  
	check_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	if [[ $check_workspace_result != *"404"* ]] ; then
		workspace_id=$(echo $check_workspace_result | jq .[].id | sed 's/"//g')
		#echo "workspace_id-sss->$workspace_id"
		if [ ! -z "$workspace_id" ]; then
			list_variables_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
			#echo "list_variables_result-->$list_variables_result"
			varid=$(echo $list_variables_result | jq '.data[] |  select(.attributes.key == "'$key'") | select(.attributes.category == "'$category'") | .id'  | sed 's/"//g')	
			#echo "varid-->$varid"
			if [ ! -z "$varid" ]; then
				sed -e "s/varid/${varid}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" -e "s/my-description/$description/" < $execdir/tempdir/variableupdate.template.json  > $execdir/tempdir/variableupdate.json
				#echo "Setting $category variable $key with value $value, hcl: $hcl, sensitive: $sensitive, with a description of $description"
				upload_variable_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request PATCH --data @$execdir/tempdir/variableupdate.json "https://${TFE_ADDR}/api/v2/workspaces/${workspace_id}/vars/${varid}")																																																					                         
				#echo "upload_variable_result-->$upload_variable_result"
				#echo "Set all variables."
			else
				#echo "varid in else --updateTFVariables>>>>>>>>>>"
				sed -e "s/my-workspace/${workspace_id}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" -e "s/my-description/$description/" < $execdir/tempdir/variable.template.json  > $execdir/tempdir/variable.json
				#echo ">>>>>>>>>>>Setting $category variable $key with value $value, hcl: $hcl, sensitive: $sensitive, with a description of $description"
				create_variable_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/variable.json "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
				#echo "create_variable_result-->$create_variable_result"
			fi
		fi
	fi	
	#rm -rf variableupdate.json
}

createTFVariables(){
	set -e
	workspace=$1
	variables_file=$2

	#echo "workspace-->>$workspace"
	#echo "variables_file-createTFVariables->>$variables_file"

	delimiter=";"
	check_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	
	#echo "workspace-NNNNNNNNNN->>$workspace"
	#echo "check_workspace_result-NNNNNNNNNN->>$check_workspace_result"
	if [[ $check_workspace_result != *"404"* ]] ; then
		workspace_id=$(echo $check_workspace_result | jq .[].id | sed 's/"//g')
		#echo "workspace_id-NNNNNNNNNN->>$workspace_id"
		if [ ! -z "$workspace_id" ]; then

			#Compltely deleting the variables from workspace
			list_variables_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
			#echo "list_variables_result-->$list_variables_result"
			echo $list_variables_result | jq '.data[] | .id'  > varids.txt
			while read varids; do
				varid=$(echo "$varids" | sed 's/"//g')
				#echo "varid-->$varid"
				if [ ! -z "$varid" ]; then
					#echo "Deleting variable ${varid}"				
					delete_variable_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request DELETE "https://${TFE_ADDR}/api/v2/vars/${varid}")																																																					                         
					#echo "delete_variable_result-->$delete_variable_result"
					#echo "Deleted all variables."
				fi
			done < varids.txt

			#Creating Fresh variables for csv
			while IFS=${delimiter} read -r key value category hcl sensitive description
			do
				#echo "key-->$key"
				#value=$(echo "$value" |sed 's,/,\\/,g')
				sed -e "s/my-workspace/${workspace_id}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" -e "s/my-description/$description/" < $execdir/tempdir/variable.template.json  > $execdir/tempdir/variable.json
				#echo "Setting $category variable $key with value $value, hcl: $hcl, sensitive: $sensitive, with a description of $description"
				create_variable_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/variable.json "https://${TFE_ADDR}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${TFE_ORG}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
				#echo "create_variable_result-->$create_variable_result"
			done < ${variables_file}
			#echo "Set all variables."
			
			updateTFVariables $workspace "AWS_ACCESS_KEY_ID" $AWS_ACCESS_KEY_ID "env" "false" "true" "AWS_ACCESS_KEY_ID"
			updateTFVariables $workspace "AWS_SECRET_ACCESS_KEY" $AWS_SECRET_ACCESS_KEY "env" "false" "true" "AWS_SECRET_ACCESS_KEY"
			updateTFVariables $workspace "AWS_REGION" $AWS_REGION "env" "false" "true" "AWS_REGION"
			updateTFVariables $workspace "aws_region" $AWS_REGION "terraform" "false" "true" "aws_region"
		fi
	fi	
	rm -rf varids.txt
}

manageTFWorkspace(){
	workspace=$1
	workspace_id=""
	check_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	if [[ $check_workspace_result != *"404"* ]] ; then
		workspace_id=$(echo $check_workspace_result | jq .[].id)	  		  							
	fi

	if [ -z "$workspace_id" ]; then
		echo "Workspace did not already exist; will create it."
		sed "s/placeholder/${workspace}/" < $execdir/tempdir/workspace.template.json > $execdir/tempdir/workspace.json
		workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @$execdir/tempdir/workspace.json "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces")
		#echo "-->>>$workspace_result"
		workspace_id=$(echo $workspace_result | jq .[].id)
	else
		echo "Workspace already existed."
	fi

	if [ -z "$workspace_id" ]; then
		echo "Workspace ID not Found in manageTFWorkspace !!, existing Now"
		exit 1
	fi
}

createConfig(){
	destroyFlag=$1
	workspace=$2
	config_dir=$3
	workspace_id=""

	workspace_id=($(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace} | jq -r '.data.id'))
	if [ ! -z "$workspace_id" ]; then
		tar -czf ${config_dir}.tar.gz -C ${config_dir} --exclude .git .
		configuration_version_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/configversion.json "https://${TFE_ADDR}/api/v2/workspaces/${workspace_id}/configuration-versions")

		if [[ $configuration_version_result != *"404"* ]] ; then
			config_version_id=$(echo $configuration_version_result | jq .[].id | sed 's/"//g')
			if [ ! -z "$config_version_id" ]; then
				
				upload_url=$(echo $configuration_version_result | jq '.data.attributes."upload-url"' | sed 's/"//g')
				${CURL_CMD} --header "Content-Type: application/octet-stream" --request PUT --data-binary @${config_dir}.tar.gz "$upload_url"
				if [ -f "${config_dir}/${env}/${targetRegion}.csv" ]; then
					variables_file=${config_dir}/${env}/${targetRegion}.csv
				else
					variables_file=${targetRegion}.csv
				fi
				if [ "$destroyFlag" == "false" ]; then
					createTFVariables "$workspace" "$variables_file" 
				fi	
			fi
		fi		
	else
		echo "Workspace not found in createConfig !!"
		exit 1
	fi	
}

runTFWorkspace(){
	workspace=$1
	manageflag=$2
	#echo "manageflag-->$manageflag"
	workspace_id=""
	save_plan="false"
	override="no"
	applied="false"
	check_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	if [[ $check_workspace_result != *"404"* ]] ; then
		workspace_id=$(echo $check_workspace_result | jq .[].id | sed 's/"//g')	  		  							
	fi

	#echo "workspace_id-RUN->>: " $workspace_id
	#echo "workspace-RUN->>: " $workspace

	if [ ! -z "$workspace_id" ]; then	
		sed "s/workspace_id/$workspace_id/" < $execdir/tempdir/run.template.json  > $execdir/tempdir/run-copy.json
		sed "s/manageflag/$manageflag/" < $execdir/tempdir/run-copy.json  > $execdir/tempdir/run.json
		#cat run.json
		run_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/run.json https://${TFE_ADDR}/api/v2/runs)
		#echo "run_result-->$run_result"
		run_id=$(echo $run_result | jq .[].id | sed 's/"//g')
		plan_id=$(echo $run_result | jq .[].relationships.plan.data.id | sed 's/"//g')
		#echo "run_id-->$run_id"
		#echo "plan_id-->$plan_id"
		
		# Check run result in loop
		continue=1
		while [ $continue -ne 0 ]; do
			sleep 5
			
			check_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/runs/${run_id})
			#echo "check_result: " $check_result
			run_status=$(echo $check_result | jq '.data.attributes.status' | sed 's/"//g')
			echo "Run Status: " $run_status
			is_confirmable=$(echo $check_result | jq '.data.attributes.actions."is-confirmable"')
			echo "is_confirmable: " $is_confirmable

			save_plan="true"
			override="yes"		
			echo "override: " $override
			if [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "true" ]] && [[ "$override" == "yes" ]]; then
				continue=0
				apply_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/apply.json https://${TFE_ADDR}/api/v2/runs/${run_id}/actions/apply)		
				#echo "apply_result--1111-->>: ${apply_result}"
				applied="true"
			elif [[ "$run_status" == "planned_and_finished" ]] && [[ "$is_confirmable" == "false" ]] && [[ "$override" == "yes" ]]; then
				continue=0
				apply_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @$execdir/tempdir/apply.json https://${TFE_ADDR}/api/v2/runs/${run_id}/actions/apply)		
				applied="true"			
			elif [[ "$run_status" == "errored" ]]; then
				echo "Plan errored or hard-mandatory policy failed"
				save_plan="true"
				exit 1
			#else
			#	# Sleep and then check status again in next loop
			#	echo "We will sleep and try again soon."
			fi
		done

		if [[ "$save_plan" == "true" ]]; then
			echo "Getting the result of the Terraform Plan."
			plan_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/runs/${run_id}?include=plan)
			plan_log_url=$(echo $plan_result | jq '.included[0].attributes."log-read-url"' | sed 's/"//g')
			
			#echo "plan_log_url-->> $plan_log_url"

			#${CURL_CMD} $plan_log_url | tee ${plan_id}1.json
            #${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --location https://${TFE_ADDR}/api/v2/plans/${plan_id}/json-output | > json-output.json
			#${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/plans/${plan_id}/json-output > ${plan_id}2.json
		    #${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/plans/${plan_id}/json-output | tee ${plan_id}3.json			
			
			#echo "plan_result-->> $plan_result"
			#echo "plan_log_url-->> $plan_log_url"
			#echo "Plan Log-->>"
			#${CURL_CMD} $plan_log_url | tee ${run_id}.log
		fi

		if [[ "$applied" == "true" ]]; then
			check_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/runs/${run_id}?include=apply)
			#echo "check_results--1111-->>: ${check_result}"
			apply_id=$(echo $check_result | jq '.included[0].id'  | sed 's/"//g')
			#echo "Apply ID-->>" $apply_id
			continue=1
			while [ $continue -ne 0 ]; do
				sleep 5
				echo "Checking apply status"
				check_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${TFE_ADDR}/api/v2/applies/${apply_id})
				#echo "check_results--2222-->>: ${check_result}"
				apply_status=$(echo $check_result | jq '.data.attributes.status' | sed 's/"//g')
				echo "Apply Status-->>${apply_status}"
				if [[ "$apply_status" == "unreachable" ]]; then
					echo "Couldn't Apply."
					continue=0
				elif [[ "$apply_status" == "finished" ]]; then
					echo "Apply finished."
					continue=0
				elif [[ "$apply_status" == "errored" ]]; then
					echo "Apply errored Please check the apply log"
					exit 1					
				else
					echo "We will sleep and try again soon."
				fi
			done

			#echo "check_results--3333-->>: ${check_result}"
			apply_log_url=$(echo $check_result | jq '.data.attributes."log-read-url"' | sed 's/"//g')
			#echo "Apply Log URL: ${apply_log_url}"

			${CURL_CMD} $apply_log_url | tee ${apply_id}.log
			state_id_before=$(echo $check_result | jq '.data.relationships."state-versions".data[1].id' | sed 's/"//g')
			#echo "State ID 1:" ${state_id_before}

			state_file_before_url_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" https://${TFE_ADDR}/api/v2/state-versions/${state_id_before})
			state_file_before_url=$(echo $state_file_before_url_result | jq '.data.attributes."hosted-state-download-url"' | sed 's/"//g')
			#echo "URL for state file before apply:" ${state_file_before_url}

			#echo "State file before the apply:"
			${CURL_CMD} $state_file_before_url | tee ${apply_id}-before.tfstate

			state_id_after=$(echo $check_result | jq '.data.relationships."state-versions".data[0].id' | sed 's/"//g')
			#echo "State ID 0:" ${state_id_after}

			# Call API to get information about the state version including its URL
			state_file_after_url_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" https://${TFE_ADDR}/api/v2/state-versions/${state_id_after})

			# Get state file URL from the result
			state_file_after_url=$(echo $state_file_after_url_result | jq '.data.attributes."hosted-state-download-url"' | sed 's/"//g')
			#echo "URL for state file after apply:" ${state_file_after_url}

			#echo "state_file_after_url-->> $state_file_after_url"
			
			#${CURL_CMD} $state_file_after_url

			#echo "State file after the apply:"
			#${CURL_CMD} $state_file_after_url | tee ${apply_id}-after.tfstate
		fi		

	fi
	#rm -rf run.json run-copy.json
}

manageAll(){
	componenet=$1
	targRegion=$2
	manageflag=$3

	#echo "manageflag-->>$manageflag"

	initiateTempFolders
	cd $execdir/tempdir
	manageTFWorkspace "$appname-$env-$targRegion-$componenet"
	createConfig "$manageflag" "$appname-$env-$targRegion-$componenet" "$execdir/tempdir/$componenet"	
	runTFWorkspace "$appname-$env-$targRegion-$componenet" "$manageflag" 	
}

deleteWorkspace(){
	if [ ! -z $1 ]; then
	workspace=$1
	echo "Using workspace provided as argument: " $workspace
	else
	echo "Using workspace set in the script."
	fi

	echo "Attempting to delete the workspace"
	delete_workspace_result=$(${CURL_CMD} --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request DELETE "https://${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces/${workspace}")
	echo "Response from TFE: ${delete_workspace_result}"
}


action=$1
env=$2
appname=$3
targetRegion=$4

if [ "$action" = "create" ]; then  
	manageAll "network" "$targetRegion"	"false"	"true" "false"
	#manageAll "storage" "$targetRegion"	"false" "true" "false"
	manageAll "application" "$targetRegion"	"false"	"true" "false"
elif [ "$action" = "destroy" ]; then
	manageAll "application" "$targetRegion"	"true" "false" "false"
	#manageAll "storage" "$targetRegion"	"true" "false" "false"
	manageAll "network" "$targetRegion"	"true" "false" "false"	
fi
