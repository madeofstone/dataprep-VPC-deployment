--------Running Locally----------
# Prerequisites 
- gcloud sdk
- kubectl

# Steps
## Initialize the glcoud running environment 
```
gcloud init
```
## Authorize the SDK to access GCP using your user account credentials and add the SDK to your PATH. This steps requires you to login and select the project you want to work in. Finally, add your account to the Application Default Credentials (ADC). This will allow Terraform to access these credentials to provision resources on GCloud.
```
gcloud auth application-default login
```

## Initiate Terraform modules in working directory
``` 
terraform init
```

## Fill in appropriate variables found in '0_variables.tf'
* Including local IP address on terraform machine *
