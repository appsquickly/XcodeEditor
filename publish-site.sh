#!/bin/sh
git checkout -b gh-pages origin/gh-pages
cp -fr build/reports/coverage/ ./coverage
git add ./coverage
cp -fr build/reports/api ./api
git add api
git commit -a -m "publish reports to gh-pages"
git push -u origin master
git checkout -b gh-pages origin/master


