# What I did before
* Imported SSL certificate to ACM
* Created ECR repository with `terrafom apply -target` in order to push Docker image
* Stored RDS credentials in SSM Parameter Store


# Future improvements

### Security
* Use IAM roles with fine tuned policies
* Enable encryption and snapshots for RDS
* Consider using Secrets Manager for storing DB credentials (SSM Parameter Store `SecureString` unencrypted value is stored in TF state as plain text)

### Monitoring
* Enable cloud watch logging, enable container insights

### Maintanance
* Get rid of hardcoding (certificate arn)
* Use TF modules
* Create ECR lifecycle policy
* Create tags for resources

### CI/CD
* Create CI/CD pipeline to automate TF deployments