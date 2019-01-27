#!/usr/bin/env bash

set -e

PREV_RELEASE=$1
RELEASE=$2

echo "PREVIOUS RELEASE version:"$PREV_RELEASE
echo "RELEASE version:"$RELEASE

if [[ -z $RELEASE ]]; then
  echo "Problem to calculate release version."
  exit 1
fi
if [[ -z $PREV_RELEASE ]]; then
  echo "Problem to calculate previous release version."
  exit 1
fi

SF_USER=romanivanov
#############################
echo "Please provide password for $SF_USER,checkstyle@shell.sourceforge.net"
echo "exit" | ssh -t $SF_USER,checkstyle@shell.sourceforge.net create

#####

mkdir -p .ci-temp
cd .ci-temp
echo "Clone by ssh only to avoid passwords on push"
git clone git@github.com:checkstyle/checkstyle.github.io.git
sсp -R checkstyle.github.io $SF_USER,checkstyle@shell.sourceforge.net:/home/project-web/checkstyle/

#############################

ssh $SF_USER,checkstyle@shell.sourceforge.net << EOF

echo "Swap html content"
cd /home/project-web/checkstyle
mv htdocs htdocs-$PREV_RELEASE
mv checkstyle.github.io htdocs
ln -s /home/project-web/checkstyle/reports htdocs/reports
echo "restore folder with links to old releases"
mv htdocs-$PREV_RELEASE/version htdocs

echo "Archiving"
tar cfz htdocs-$PREV_RELEASE.tar.gz htdocs-$PREV_RELEASE/
mv htdocs-$PREV_RELEASE.tar.gz htdocs-archive/
rm -rf htdocs-$PREV_RELEASE/

echo "Extracting archive to previous releases documentation"
tar -xzvf htdocs-archive/htdocs-$PREV_RELEASE.tar.gz -C htdocs-version/ \
--exclude="*/apidocs" \
--exclude="*/xref" --exclude="*/xref-test" --exclude="*/cobertura" --exclude="*/dsm" \
--exclude="*/api" --exclude="reports" --exclude="jacoco" --exclude="dtds" \
--exclude="dependency-updates-report.html" --exclude="plugin-updates-report.html" \
--exclude="jdepend-report.html" --exclude="failsafe-report.html" \
--exclude="surefire-report.html" \
--exclude="linkcheck.html" --exclude="findbugs.html" --exclude="taglist.html" \
--exclude="releasenotes_old.html" --exclude="dependencies.html"
echo "Make a link to make it accessible from web"
ln -f -s htdocs-version/htdocs-$PREV_RELEASE htdocs/version/$PREV_RELEASE

EOF
