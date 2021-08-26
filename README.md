# SlimPickens

![robot-3610901_640](https://user-images.githubusercontent.com/42816/128962538-d81101dd-11c1-473b-895d-aad10b4c32f1.png)


This is a simple tool that helps with a specific cherry-picking strategy where we need to cherry-pick commits from
qa -> stage, then stage -> prod (subsitute any branch names you want for those).

## The Problem

I was performing the same steps for each feature:

* merge my feature to QA
* validate and test
* checkout QA
* pull latest QA
* `git log` to find the commits I want to cherry-pick and keep results on the screen
* open a new termial window
* checkout Stage
* pull latest Stage
* create a new branch, then `git cherry-pick` all relevent commits from the results of `git log`
* `git push` and create a PR

Once my Stage PR is merged and tested:

* pull latest Stage
* `git log` to find the commits I want to cherry-pick and keep results on the screen
* open a new pane
* checkout Prod
* pull latest Prod
* create a new branch, then `git cherry-pick` all relevent commits from the `git log`
* `git push` and create a PR

Once I got into this rhythm, it felt like an appropriate time to build an automation to
reduce the number of steps needed

## The Solution

Automate most of this leaving the user to just specifiy the correct branches and commit hashes

[![asciicast](https://asciinema.org/a/nLszBBjuSWjOzfvZFnKiaDWRh.png)](https://asciinema.org/a/nLszBBjuSWjOzfvZFnKiaDWRh)

By default, the tool only shows the current users commit in the commit logs by using the `user.email` field in the git global config.
If there is no value there, the tool will show all recent commits.

## Installation
[Download the latest release for your OS](https://github.com/silbermm/slim_pickens/releases) in the Assests section (currently only Mac and Linux x64 are supported) and put the binary somewhere in your path. For example, on an Arch distro, I put it in `/usr/local/bin`.

## Step-by-step Installation & Setup For Mac
1.  Once you've downloaded the [latest release for your OS](https://github.com/silbermm/slim_pickens/releases),
find the download on your local machine:  
    ```bash
    cd Downloads
    ```

2.  Make the file executable:
    ```bash
    chmod +x slim_darwin
    ```
    <em>If this doesn’t work for you, check that your terminal is listed as an app for “Full Disk Access” under Security & Privacy.</em>


3.  Confirm the file is executable: 
    ```bash
    ls -l slim_darwin
    ```
    
4.  Try out a Slim command:
    ```bash
    ./sim_darwin --help
    ```
    <em>If you receive an error that macOS cannot verify the developer, open slim_picken in finder holding down the `option` button. You'll get a prompt to click `open`.

5.  Copy this file to your user directory so that you can use slim commands outside of Downloads directory: 
    ```bash
    sudo cp slim_darwin /usr/local/bin/slim
    ```
6.  cd out of downloads and into a project:
    ```bash
    cd ../YOUR_PROJECT_NAME
    ```
7. confirm Slim works outside of downloads:
    ```bash
    slim
    ```

You have successfully set up Slim!

## Usage

Use
```bash
slim pick [from_branch_name] --to [final_destination_branch_name]
```

This will present the you with a list of commits in the `[from_branch_name]`

Enter the commits you want to cherry-pick *in the correct order* delimited by spaces

```
> slim pick qa --to stage
  [1] 1d31135 (HEAD -> main) cleanup commands to use help() from macro
  [2] 7b9782a (origin/main) keep docs
  [3] ba08289 rename show to find
  [4] 5a46d7e save table after deleteing

Choose a commits to cherry-pick in order [1-5]: 3 2 1
```

## Help

Simple help can be found using the `--help` flag.

If you need more help, create an [issue](https://github.com/silbermm/slim_pickens/pulls)
