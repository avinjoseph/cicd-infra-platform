# CI/CD & Infrastructure Automation Platform

A small but complete DevOps pipeline demonstrating GitHub Actions, Docker,
Terraform, and AWS-style infrastructure automation — built to run **entirely
for free**, with no AWS account or credit card required.

## What this project demonstrates

- **CI/CD pipeline (GitHub Actions)**: automated testing, static analysis,
  dependency vulnerability scanning, Docker image builds, and deployment —
  triggered on every push and pull request.
- **Infrastructure as Code (Terraform)**: an ECS Fargate service, ECR
  repository, S3 bucket, IAM roles, and CloudWatch logging, fully
  version-controlled and reproducible from a single `terraform apply`.
- **Deployment validation & rollback**: after a deploy, a health-check
  script polls the new release; if it fails, an automatic rollback script
  reverts the ECS service to the previous task definition revision. ECS's
  built-in deployment circuit breaker provides a second layer of
  protection.

## How this runs at zero cost

| Resume item | Normally costs money because... | How this project avoids that |
|---|---|---|
| GitHub Actions | Private repos get limited free minutes | Repo is public → **unlimited free minutes** on standard runners |
| Docker registry | Docker Hub / ECR can have costs or limits | Images are pushed to **GitHub Container Registry (GHCR)**, free for public repos |
| AWS + Terraform | Real ECS/ALB/NAT gateways cost money per hour | Terraform is pointed at **[LocalStack](https://www.localstack.io/)**, an open-source local AWS emulator that runs in a Docker container on `localhost`. `terraform plan`/`apply` work against it exactly like real AWS, with $0 spend |

The `terraform-validate` job in the pipeline spins up LocalStack as a
GitHub Actions service container and runs `terraform init/validate/plan`
against it automatically — no secrets or AWS account needed to see the
pipeline pass end-to-end.

If you *do* want to eventually point this at a real AWS account (e.g. to
put a live demo link on your resume), everything is designed to make that
a one-line change:

```hcl
# terraform/terraform.tfvars
use_localstack = false
```

...plus real AWS credentials in GitHub Actions secrets. Stick to
[AWS Free Tier](https://aws.amazon.com/free/) eligible resources (this
stack's default sizing — one Fargate task, S3, ECR — fits comfortably
within it) and set a billing alarm as a safety net.

## Project structure

```
.
├── .github/workflows/ci-cd.yml   # Full pipeline: test → scan → build → validate infra → deploy
├── app/                          # Sample FastAPI service (the "thing" being deployed)
│   ├── main.py
│   ├── requirements.txt
│   └── tests/test_main.py
├── docker/Dockerfile             # Multi-stage, non-root, with a container HEALTHCHECK
├── terraform/                    # IaC: ECS Fargate, ECR, S3, IAM, CloudWatch
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf               # Defaults to LocalStack — zero cost
├── scripts/
│   ├── validate_deployment.sh    # Polls /health after deploy
│   └── rollback.sh               # Reverts ECS service to prior revision on failure
└── docker-compose.yml            # Run app + LocalStack together locally
```

## Running it yourself (free)

**1. Run the app locally:**
```bash
cd app
pip install -r requirements-dev.txt
uvicorn main:app --reload
# -> http://localhost:8000/health
```

**2. Run the full local stack (app + LocalStack):**
```bash
docker compose up --build
```

**3. Provision infrastructure against LocalStack:**
```bash
cd terraform
terraform init
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  terraform apply
```

**4. Run tests, lint, and scans:**
```bash
pip install -r app/requirements-dev.txt
ruff check app
pytest app/tests -v
bandit -r app -x app/tests
pip-audit -r app/requirements.txt
```

**5. See the pipeline itself:**
Push to a public GitHub repo and every stage — test, static analysis,
dependency scan, Docker build/push to GHCR, and Terraform validate/plan
against LocalStack — runs automatically and for free in the Actions tab.
The final `deploy` job (real AWS apply + health validation + rollback) is
gated behind a GitHub Environment and real AWS secrets, so it only runs if
you choose to wire up an actual AWS account.

## Why this design is resume-worthy

- Shows the **full pipeline lifecycle**: test → scan → build → provision →
  deploy → validate → rollback, not just "runs some tests."
- Shows **IaC discipline**: infra is code-reviewed, formatted, validated,
  and planned in CI before anything touches real infrastructure.
- Shows **release safety practices**: automated health-check gating,
  ECS deployment circuit breaker, and a scripted rollback path — the exact
  things the resume bullet calls out ("automated deployment validation and
  rollback checks").
- Runs **completely free**, so it's easy for anyone reviewing your resume
  to clone it and watch the pipeline pass in their own fork.
