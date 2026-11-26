# GitHub Actions CD
- To Learn about Self-hosted Runners
- To Deploy your Demo Projects

# Runners
## (1) Github Runner
- Ubuntu-latest (Ephermal Container)

## (2) Self-Hosted Runner
- (Long live container)

====================================================
# Step.1 Deploy your Project on Self-Hosted Runner
- Create an EC2 instance on AWS

## Step.2 Login to Github
- Go to Same Repository
- Setting
- Actions (left side-bar)
- Runners
- New self-hosted Runner (Button at Top right side)
- Runner Image:- Linux

## Step.3 Run All these cmd on EC2
```
****** Download ******

# Create a folder
$ mkdir actions-runner && cd actions-runnerCopied

# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.338.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.338.2/actions-runner-linux-x64-2.338.2.tar.gzCopied

# Optional: Validate the hash
$ echo "baebf204307bac6193480852732f0aba2ae97b6c5597c244f4d5558390147c40  actions-runner-linux-x64-2.338.2.tar.gz" | shasum -a 256 -c

# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.338.2.tar.gz


****** Configure *******

# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/ankittripathidev/devboard-frontend --token BB7GMCTM7PARTLOT3HXMLULLBA4IO


# Runner Registration:- This Will Ask to you

(i) Enter the name of the runner group to add this runner to: [press Enter for Default] 
- Enter 

(ii) Enter the name of runner: [press Enter for ip-172-31-45-72]
- self-hosted

(iii) This runner will have the following labels: 'self-hosted', 'Linux', 'X64' 
Enter any additional labels (ex. label-1,label-2): [press Enter to skip] 
- Enter

√ Runner successfully added

# Runner settings

(iv) Enter name of work folder: [press Enter for _work] 
- devboard-work (your custom Name) 

√ Settings Saved.

ubuntu@ip-172-31-45-72:~/actions-runner$ 
-  ./run.sh 
```

# Step.4 Go to Runner 
- self-hosted self-hosted Linux X64    Offline  
- Refresh it
- self-hosted self-hosted Linux X64    Idle 

# Step.5 Your Project Repo .github/workflows/ci.yml 
# This is CI Part
```
# Goal: Lint, Test, Build Frontend & Backend
# Then Push Docker Images to DockerHub

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
      - name: Checkout Code/ Code Clone
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
      - name: Checkout Code/ Code Clone
        uses: actions/checkout@v7

      # Setup Go
      - name: Setup Go
        uses: actions/setup-go@v7
        with:
          go-version-file: ./backend/go.mod
          cache-dependency-path: ./backend/go.sum

      # Check Go formatting without modifying files
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

# Step:6 Install Docker & docker compose on EC2
- sudo apt update && upgrade -y
- sudo apt install docker.io && docker-compose-v2 -y

## Give permission to docker
- sudo usermod -aG docker $USER
- newgrp docker
- docker ps




# Step.7 Now for Self-Hosted CD (For Deployment)
```

```