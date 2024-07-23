## github-track

This is another weird problem, i was thinking about...
Let's say, you're working on your projects hosted on alternatives from github, but you still want to track your dev activity ON github chart.
YES, that's what this `.git/hook` does.

## HOW TO

- Create the repo activity-repo in your github.
- Set your github activity env var:

```bash
$ export GITHUB_ACTIVITY_REPO=git@github.com:<your-github-handle>/activity-repo.git
```
- Copy ./github-track.sh and ./post-commit (or just the content if a post-commit file is already present) in your `.git/hook` project.

And that's it.

Each time you're going to make a commit on any other host, this hook will create an activity record and push it to your 'github-activity-repo'.
