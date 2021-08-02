# SlimPickens

This is a simple tool that helps with a specific cherry-picking strategy where we need to cherry-pick commits from
qa -> stage, then stage -> prod (subsitute any branch names you want for those).

## The Problem

I was performing the same steps for each feature:

* merge my feature to QA
* validate and test
* pull latest QA
* `git log` to find the commits I want to cherry-pick and keep results on the screen
* open a new pane and checkout Stage
* pull latest Stage
* create a new branch, then `git cherry-pick` all relevent commits from the `git log`
* `git push` and create a PR

Once my Stage PR is merged and tested:

* pull latest Stage
* `git log` to find the commits I want to cherry-pick and keep results on the screen
* open a new pane and checkout Prod
* pull latest Prod
* create a new branch, then `git cherry-pick` all relevent commits from the `git log`
* `git push` and create a PR

Once I got into this rhythm, it felt like an appropriate time to build an automation to
reduce the number of steps needed

## The Solution

Automate most of this leaving the user to just specifiy the correct branches and commit hashes

```bash
> slim qa --to stage
  [1] 1d31135 (HEAD -> main) cleanup commands to use help() from macro
  [2] 7b9782a (origin/main) keep docs
  [3] ba08289 rename show to find
  [4] 5a46d7e save table after deleteing
  [5] Show More

Choose a commit to cherry-pick or show more [1-5]:
```

By default, the tool only shows the current users commit in the commit logs by using the `user.email` field in the git global config.
If there is no value there, the tool will show all recent commits. slim also accepts the `--author` field with will just pass to
`git log --author <>`

## Installation
TODO

## Help
TODO
