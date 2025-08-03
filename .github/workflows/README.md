# GitHub Actions Setup for Terraform

This directory contains GitHub Actions workflows for managing Terraform infrastructure.

## Workflows

### 1. `terraform-plan.yml` - Automated Planning
**Triggers:**
- Pull requests to `main`/`master` (when terraform files change)
- Pushes to `main`/`master` (when terraform files change)

**Features:**
- 🔍 Runs `terraform plan` on every PR
- 📝 Comments plan results directly on PR
- ✅ Format checking, validation, and security scanning
- 📦 Uploads plan artifacts
- 🔒 Uses AWS access keys for authentication

### 2. `terraform-apply.yml` - Manual Deployment
**Triggers:**
- Manual workflow dispatch only

**Features:**
- 🚀 Deploys infrastructure changes
- 🛡️ Requires confirmation input ("apply")
- 🌍 Environment selection (prod/staging)
- 📊 Shows terraform outputs in summary

> **Note:** Terraform destroy operations should be performed manually from your local environment for safety.

## Setup Requirements

### GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key |
| `AWS_REGION` | AWS region for deployment |

### IAM User Permissions

Your AWS user should have these policies attached:
- `IAMFullAccess` (for managing IAM resources)
- `AmazonS3FullAccess` (for state backend)
- `AmazonBedrockFullAccess` (for Bedrock resources)
- Custom policy for additional Terraform permissions

### GitHub Environments (Optional)

For additional security, create GitHub environments:
1. Go to Settings → Environments
2. Create `prod` and `staging` environments
3. Add protection rules (required reviewers, deployment branches)

## Usage

### Planning (Automatic)
1. Create a PR with Terraform changes
2. Workflow automatically runs and comments results
3. Review the plan in the PR comment

### Deploying (Manual)
1. Go to Actions → Terraform Apply
2. Click "Run workflow"
3. Select environment and type "apply" to confirm
4. Monitor the deployment

### Destroying (Manual - Local Only)
For safety, destroy operations should be performed from your local environment:
```bash
cd terraform
terraform plan -destroy
terraform destroy  # Only after reviewing the destroy plan
```

## Security Features

- 🔒 **AWS Access Keys**: Secure credential management via GitHub secrets
- � **User Authorization**: Only specified users can run terraform apply
- �🛡️ **Environment Protection**: Manual approval for deployments
- 🔍 **Security Scanning**: Checkov scans for misconfigurations
- 📝 **Audit Trail**: All actions logged with actor and reason
- ✅ **Confirmation Required**: Must type exact confirmation words

### Public Repository Security

If your repository is public, the workflows include additional security measures:
- **User Authorization**: Only users in the `ALLOWED_USERS` list can run terraform apply
- **Environment Protection**: GitHub environments can require approval from repository owners
- **No Secrets Exposure**: AWS credentials are stored as encrypted repository secrets

To modify allowed users, edit the `ALLOWED_USERS` variable in `terraform-apply.yml`.

## Customization

To customize for your setup:

1. **Change regions**: Update `AWS_REGION` in workflow files
2. **Add environments**: Modify environment choices in workflow inputs
3. **Adjust permissions**: Update IAM policies based on your needs
4. **Add notifications**: Integrate with Slack/Teams for deployment alerts

## Troubleshooting

### Common Issues

**AWS Authentication Fails:**
- Check that AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set correctly
- Verify the IAM user has the required permissions
- Ensure AWS_REGION is set to a supported region

**Terraform Init Fails:**
- Ensure S3 backend bucket exists and is accessible
- Check IAM permissions for S3 access

**Plan/Apply Fails:**
- Verify all required secrets are set
- Check that Lambda function name is correct
- Ensure Bedrock is available in your region

### Debugging

Enable debug logging by adding this to workflow files:
```yaml
env:
  TF_LOG: DEBUG
  ACTIONS_STEP_DEBUG: true
```
