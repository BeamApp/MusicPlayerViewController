#!/bin/sh
set -e

if [ "$1" ] 
then
  cd "$1"
fi

/usr/local/bin/appledoc --project-name BeamMusicPlayerViewController --project-company "BeamApp UG" --company-id com.beamapp --output ./Documentation --no-create-docset --no-repeat-first-par --logformat xcode --warn-undocumented-member --warn-empty-description --warn-undocumented-object --keep-undocumented-members --keep-undocumented-objects --verbose 4 ./Source/BeamMusicPlayerViewController.h ./Source/BeamMusicPlayerDataSource.h ./Source/BeamMusicPlayerDelegate.h