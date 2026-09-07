#!/bin/bash

#Take a file name as an argument or exit if not provider
if [ -z "$1" ]; then
	echo "Usage: $0  <file-name>"
	exit 1
fi


# Genarate a bucket name
BUCKET_NAME="daws-s3-simple-$(date +%y%m%d)"

# Check if the bucket already exists, create if not.
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
	echo "Creating bucket: $BUCKET_NAME"
	aws s3api create-bucket \
	    --bucket "$BUCKET_NAME"

	aws s3api put-bucket-ownership-controls \
	    --bucket "$BUCKET_NAME" \
	    --ownership-controls "Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

	aws s3api put-public-access-block \
	    --bucket "$BUCKET_NAME" \
	    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
else
	echo "Bucket already exists: $BUCKET_NAME"
fi

# Upload the file to the bucket
aws s3 cp "$1" "s3://$BUCKET_NAME/" --acl public-read
if [ $? -eq 0 ]; then
	echo "File '$1' uploaded successfully to 's3://$BUCKET_NAME/'"
else
	echo "Failed to upload file '$1'"
	exit 1
fi

#Prints the public URL of the uploaded file
File_NAME=$(basename "$1")
PUBLIC_URL="https://$BUCKET_NAME.s3.amazonaws.com/$File_NAME"
echo "Public URL: $PUBLIC_URL"

# 1.Publish cost
# 604 KB = 0.0005903244 GB
# Storage: 0.0005903244 GB * $0.023/GB = $0.00001357
# PUT Rquest = 1 * $0.005/1000 = $0.000005
# Total cost = $0.0000136 + $0.000005 = $0.00001857

# 2.Download cost
# GET Request = 1 * $0.0004/1000 = $0.0000004
# Outbound Network Transfer = 0.0005903244 GB * $0.09/GB = $0.00005313
# Total cost = $0.0000004 + $0.00005313 = $

# 3. How to protect the bucket?
# There are several ways to protect the bucket. We'll learn more
# about that as we progress, but here are some refrences:
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices
# * Use AWS Shield: https://aws.amazon.com/shield/
# * Use temporary, signed URLs: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html
# * Use Amazon Cognito for user authentication and authorization: https://aws.amazon.com/cognito/

