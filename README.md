# SlimPickens

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

[![asciicast](https://asciinema.org/a/14.png)](https://asciinema.org/a/nLszBBjuSWjOzfvZFnKiaDWRh)

By default, the tool only shows the current users commit in the commit logs by using the `user.email` field in the git global config.
If there is no value there, the tool will show all recent commits.

## Installation
[Download the latest release for your OS](https://github.com/silbermm/slim_pickens/releases) in the Assests section (currently only Mac and Linux x64 are supported) and put the binary somewhere in your path. For example, on an Arch distro, I put it in `/usr/local/bin`.

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
