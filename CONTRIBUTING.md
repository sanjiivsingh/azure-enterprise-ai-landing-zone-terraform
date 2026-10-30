# Contributing Guidelines

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Validate Terraform:
   ```bash
   terraform fmt -check -recursive
   cd environments/dev && terraform validate
   ```
3. Submit PR targeting `main`.
