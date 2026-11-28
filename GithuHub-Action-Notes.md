# Day-3 GitHub Actions CD  – Self-Hosted Runner & Deployment

- Learn about Self-Hosted Runners
- Deploy Demo Projects using GitHub Actions

---

# Runners

## (1) GitHub-Hosted Runner
- `ubuntu-latest`
- Ephemeral Environment (Temporary)

## (2) Self-Hosted Runner
- Runs on your own EC2 instance
- Persistent Environment (Long-Lived)

---

# Step 1 – Create an EC2 Instance on AWS

- Launch an EC2 instance on AWS.
- Connect to the instance using SSH.

# Step 2 – Configure GitHub Self-Hosted Runner

- Go to your GitHub Repository.
- Settings
- Actions (Left Sidebar)
- Runners
- Click **New self-hosted runner** (Top Right).
- Runner Image: Linux

# Step 3 – Install & Configure Runner on EC2

Run the following commands on EC2.

### Download

```bash
# Create a folder
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.338.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.338.2/actions-runner-linux-x64-2.338.2.tar.gz

# Optional: Validate the hash
echo "baebf204307bac6193480852732f0aba2ae97b6c5597c244f4d5558390147c40  actions-runner-linux-x64-2.338.2.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.338.2.tar.gz
```

### Configure

```bash
./config.sh --url https://github.com/ankittripathidev/devboard-frontend --token YOUR_TOKEN
```

### Runner Registration

During configuration, provide the following details:

**(i) Runner Group**
```text
Enter the name of the runner group to add this runner to: [press Enter for Default]
- Press Enter
```

**(ii) Runner Name**
```text
Enter the name of runner:
- self-hosted
```

**(iii) Additional Labels**
```text
Enter any additional labels:
- Press Enter to skip
```

Default labels:
- self-hosted
- Linux
- X64

**(iv) Work Folder**
```text
Enter name of work folder: [press Enter for _work]
- devboard-work
```

- Runner successfully added.
- Settings saved.

### Start Runner

```bash
./run.sh
```

# Step 4 – Verify Runner Status

Go to:

GitHub Repository → Settings → Actions → Runners

Initially:
```text
self-hosted   self-hosted   Linux   X64   Offline
```

After running `./run.sh`:
```text
self-hosted   self-hosted   Linux   X64   Idle
```

# Step 5 – Configure GitHub Actions CI

File: `.github/workflows/ci.yml`

**Goal:** Lint, Test and Build Frontend & Backend, then push Docker images to DockerHub.

### CI Workflow

```yaml
name: CI

on:
  push:
    branches:
      - advanced

jobs:
  # Job-1: Build Frontend
  build-frontend:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v7

      # Setup Node.js
      - name: Setup Node.js
        uses: actions/setup-node@v7
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: ./frontend/package-lock.json

      # Install Dependencies
      - name: Install npm Packages
        run: npm ci
        working-directory: ./frontend

      # Lint
      - name: Run Linter
        run: npm run lint
        working-directory: ./frontend

      # Test
      - name: Run Tests
        run: npm run test
        working-directory: ./frontend

      # Docker Login
      - name: Docker Login
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Docker Build & Push
      - name: Docker Build and Push
        uses: docker/build-push-action@v7
        with:
          context: ./frontend
          push: true
          tags: ${{ vars.DOCKERHUB_USERNAME }}/devboard-frontend:latest


  # Job-2: Build Backend
  build-backend:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v7

      # Setup Go
      - name: Setup Go
        uses: actions/setup-go@v7
        with:
          go-version-file: ./backend/go.mod
          cache-dependency-path: ./backend/go.sum

      # Check Go Formatting
      - name: Check Go Formatting
        working-directory: ./backend
        run: |
          files=$(gofmt -l .)

          if [ -n "$files" ]; then
            echo "The following files need formatting:"
            echo "$files"
            exit 1
          fi

          echo "All Go files are properly formatted!"

      # Lint
      - name: Go-lang Linter
        uses: golangci/golangci-lint-action@v9
        with:
          version: v2.13
          working-directory: ./backend

      # Go Vet
      - name: Run Go Vet
        run: go vet ./...
        working-directory: ./backend

      # Test
      - name: Run Tests
        run: go test -v -race ./...
        working-directory: ./backend

      # Docker Login
      - name: Docker Login
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Docker Build & Push
      - name: Docker Build and Push
        uses: docker/build-push-action@v7
        with:
          context: ./backend
          push: true
          tags: ${{ vars.DOCKERHUB_USERNAME }}/devboard-backend:latest
```

# Step 6 – Install Docker & Docker Compose on EC2

```bash
# Update package lists
sudo apt update

# Install Docker and Docker Compose plugin
sudo apt install -y docker.io docker-compose-v2
```

### Give Docker Permission

```bash
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify Docker
docker ps
```

# Step 7 – Configure GitHub Actions CD

File: `.github/workflows/cd.yml`

**Goal:** Deploy Docker images on EC2 after successful CI.

### CD Workflow

```yaml
name: CD

on:
  workflow_call:

permissions:
  contents: read

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Checkout Code
        uses: actions/checkout@v7

      # Copy Example env to Main env
      - name: Copy Example env to Main env
        run: cp .env.example .env

      # Docker Login
      - name: Docker Login
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Deploy with Docker Compose
      - name: Deploy with Docker Compose
        run: |
          docker compose pull
          docker compose up -d
```

# Step 8 – Start Self-Hosted Runner on EC2

If the runner is not connected to GitHub, start it manually.

```bash
cd ~/actions-runner

./run.sh
```

**Note:** If you have installed the runner as a system service, use `sudo ./svc.sh start` instead of running `./run.sh` separately.

# Step 9 – Verify Deployment

- Check GitHub Actions workflow execution.
- Verify that the CD job runs on the self-hosted runner.
- Check Docker containers on EC2.

```bash
docker ps
```

# Step 10 – Configure EC2 Security Group

Go to:

AWS → EC2 → Security Groups → Select Security Group → Edit Inbound Rules

Add the required application ports.

Example:

| Service | Port |
|---|---:|
| Frontend | 8080 |

- Protocol: TCP
- Port: 8080
- Source: Your required access range.

# Step 11 – Access Project in Browser

```text
http://EC2-PUBLIC-IP:8080
```

---

# Deployment Flow

```text
Developer Pushes Code
        |
        v
GitHub Repository
        |
        v
GitHub Actions CI
(GitHub-Hosted Runner)
        |
        v
Lint → Test → Build
        |
        v
Push Docker Images
     (DockerHub)
        |
        v
GitHub Actions CD
(Self-Hosted Runner)
        |
        v
EC2 Instance
        |
        v
Docker Compose Pull
        |
        v
Docker Compose Up -d
        |
        v
Application Deployed
```
