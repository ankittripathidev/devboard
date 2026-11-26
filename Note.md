# GitHub Actions CD

- To Learn about Self-hosted Runners
- To Deploy your Demo Projects

# Runners

- (1) Github Runner:- Ubuntu-latest (Ephermal Container)
- (2) Self-Hosted:- (Long live container)

# Self-Hosted Runner

## step.1 create Ec2 instance

## step.2 Go to github

- Repository
- Setting
- Actions(left side bar)
- Runners
- New self-hosted Runner
- Runner Image:- Linux

## Step.3 Run All cmd on EC2

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
- devboard-work  

√ Settings Saved.

ubuntu@ip-172-31-45-72:~/actions-runner$ 
-  ./run.sh 
```

# Step.5 Go to Runner 
- self-hosted self-hosted Linux X64    Offline  
- Refresh it
- self-hosted self-hosted Linux X64    Idle 


