#!/bin/sh

eval "$(ssh-agent -s)" #start the ssh agent
chmod 600 travis-ci
ssh-add travis-ci
cd _site
git init
git config --global user.email "$GIT_EMAIL"
git config --global user.name  "$GIT_NAME"
git remote add deploy "deploy@git.urbanslug.com:blog.git"
git add --all
git status
git commit -m "Built by Travis ( build $TRAVIS_BUILD_NUMBER )"
git push -q --force deploy master:master
