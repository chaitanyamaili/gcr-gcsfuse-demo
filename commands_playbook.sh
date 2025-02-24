#Commands Playbook
#Set Custom variables
export PROJECT_ID=<project>
export REGION=<region>
export BUCKET=<bucket>

#Setting up gcloud defaults
#Set your default project:
gcloud config set project $PROJECT_ID
#Configure gcloud for your chosen region:
gcloud config set run/region $REGION
gcloud config set builds/region $REGION

#Service Account Creation
#Create a service account to serve as the service identity:
gcloud iam service-accounts create gcsfuse-cr-identity
#Grant the service account access to the Cloud Storage bucket:
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:gcsfuse-cr-identity@$PROJECT_ID.iam.gserviceaccount.com" --role "roles/storage.objectAdmin"

#Setting up the Cloud Storage Bucket
#Create a bucket:
gcloud storage buckets create gs://$BUCKET --public-access-prevention
#Copy files from you local dir to Cloud Storage Bucket
gcloud storage cp assets/index.html gs://$BUCKET 
#Alternatively you can upload files using the gsutil rsync
#You can use the -R option to recursively copy directory trees. For example, to synchronize a local directory named local-dir with a bucket, use the following:
gsutil rsync -R assets gs://$BUCKET

#Creating the Cloud Run Service
#Ensure you are in the root of this directory
#This will create a Cloud Run service with name cloudrun-static-demo that will be accessible from anywhere
gcloud run deploy cloudrun-static-demo --source . --execution-environment gen2 --allow-unauthenticated --service-account gcsfuse-cr-identity --set-env-vars=BUCKET=$BUCKET --port 8080
