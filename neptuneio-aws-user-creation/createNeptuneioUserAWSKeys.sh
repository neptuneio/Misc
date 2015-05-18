#!/bin/bash

echo -e "-------------------------------------------------"
echo -e "Step 1 : Checking if AWS-CLI is installed"
echo -e "-------------------------------------------------\n"

if which aws ; then
  echo -e "AWS CLI is installed ! Good to go\n"
else
echo -e "\n#################################################"
  echo -e "AWS CLI is not installed; Please install AWS CLI and rerun this script, or follow www.neptune.io/documentation steps to create your keys on AWS console\n"
echo -e "#################################################\n"
  exit 1;
fi

echo -e "-------------------------------------------------"
echo -e "Step2 : Creating a new user NeptuneioUser"
echo -e "-------------------------------------------------\n"

if aws iam create-user --user-name NeptuneioUser ; then
  echo -e "Successfully created Neptune user\n"
else
echo -e "\n#################################################"
  echo -e "An user with same name NeptuneioUser already exists, or you might not have right permissions to create a new user; Please rerun this script with right permissions"
echo -e "#################################################\n"
  exit 1;
fi

echo -e "-------------------------------------------------"
echo -e "Step 3 : Fetching the policy"
echo -e "-------------------------------------------------\n"

curl -sS -O https://raw.githubusercontent.com/neptuneio/Misc/prod/neptuneio-aws-user-creation/NeptuneioUserPolicy.json

if ls NeptuneioUserPolicy.json ; then
  echo -e "\nSuccessfully downloaded Policy"
else
echo -e "\n#################################################"
  echo -e " Unable to download policy; Please check if you have internet access and rerun the script"
echo -e "#################################################\n"
# Delete user so that script rerun doesn't fail with existing user name
aws iam delete-user --user-name NeptuneioUser;
  exit 1;
fi

echo -e "-------------------------------------------------"
echo -e "Step 4 : Attaching the policy to the user"
echo -e "-------------------------------------------------\n"
aws iam put-user-policy --user-name NeptuneioUser --policy-name NeptuneioUserPolicy --policy-document file://NeptuneioUserPolicy.json

echo -e "-------------------------------------------------"
echo -e "Step 5 : Checking if NeptuneioUser has the policy attached"
echo -e "-------------------------------------------------\n"

if aws iam list-user-policies --user-name NeptuneioUser | grep NeptuneioUserPolicy ; then
echo -e "Successfully attached policy to NeptuneioUser"
else
echo -e "\n#################################################"
  echo -e "Couldn't attach policy to NeptuneioUser; Please follow steps at www.neptune.io/documentation to create AWS Keys for NeptuneioUser on your AWS console; Also save the keys for future use"
echo -e "#################################################\n"
# Delete user so that script rerun doesn't fail with existing user name
aws iam delete-user --user-name NeptuneioUser;
exit 1;
fi

echo -e "-------------------------------------------------"
echo -e "Step 6 : Creating an AccessKey for NeptuneioUser"
echo -e "-------------------------------------------------\n"

if aws iam create-access-key --user-name NeptuneioUser; then

echo -e "\n#################################################"
echo -e "SUCCESSFULL ! From Step 6 above, please copy and paste AccessKeyId, SecretAccessKey to Neptune.io graphical console"
echo -e "#################################################\n"

else
echo -e "\n#################################################"
  echo -e "Unable to create AccessKeyId for new user NeptuneioUser; Check your AWS permissions and rerun the script"
echo -e "#################################################\n"
# Clean up
rm NeptuneioUserPolicy.json
# Delete user so that script rerun doesn't fail with existing user name
aws iam delete-user --user-name NeptuneioUser;
exit 1;
fi


# Clean up
rm NeptuneioUserPolicy.json
