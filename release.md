# Release

Releases are named with semantic version numbers vX.Y.Z and published on
[DockerHub](https://hub.docker.com/u/arturklauser/gnucash). For this procedure,
we assume all changes are already checked in a verified, i.e., the last push to
github has passed the CI/CD pipeline and the resulting `gnucash:latest` image
has been (manually) verified to contain all desired features for the release.

## Steps to Create a Release

* Pick a new release number. Whether X, Y, or Z should be incremented depends on
  the type of changes between the previous release and the current one (see
  [semantic versioning](https://semver.org) for guidance).
* Search for the old release number in the repo tree and replace it everywhere
  with the new release number. E.g., assume the old release was `v1.2.3` and the
  new one is `v1.3.0`:
  ```
  grep -lR "v1\.2\.3" | xargs -I {} sed -i.bak 's/v1\.2\.3/v1.3.0/g' {}
  ```
* Check if the changes look correct and fix any mistakes:
  ```
  git diff
  ```
* Commit the changes to the git main branch:
  ```
  git add -u
  git commit -m "Release v1.3.0"
  ```
* Create a release tag:
  ```
  git tag -a v1.3.0
  ```
  As the tag message put it:
  ```
  Version 1.3.0

  <short description of major changes>
  ...
  ```
* Push both the branch HEAD and the tag to github. Assuming the github remote is
  called `origin` (check with `git remote -v`):
  ```
  git push origin main v1.3.0
  ```
  The push of the tag will trigger a CI/CD run that tags the image pushed to
  DockerHub with the release tag number, instead of "latest". It will also
  trigger a "release" job at the end of the CI/CD pipeline that will create a
  [*draft* release on github][1].
  [1]: https://github.com/ArturKlauser/docker-gnucash/releases
* Open the draft release, describe all pertinent changes, check "Set as the
  latest release", and "Publish release" when you're happy with it.
