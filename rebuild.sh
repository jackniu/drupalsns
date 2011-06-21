#!/bin/bash

# Build core first.
if [ -d drupal ]; then
	rebuild='n';
	echo -e "Rebuild core ? [Y/n] \c";
	read REBUILD;
	if [ $REBUILD = 'y' ]; then
		rm -rf drupal
		drush make config/core.make drupal -y;
	fi;
else
	drush make config/core.make drupal -y;
fi;

# Build contrib package.
drush make --no-core --contrib-destination=temp_all config/standard.make -y;

# Build development tools if need.
DEVELOP="n";
echo -e "Build development tools? [Y/n]: \c";
read DEVELOP;
if [ $DEVELOP = "y" ]; then
  drush make --no-core --contrib-destination=temp_all config/develop.make -y;
fi;

case "$1" in
	-[yY])
		SELECTION="y";
		;;
	*)
		echo -e "Replace all projects? [Y/n]: \c";
		read SELECTION;
		;;
esac

case "$SELECTION" in
	[nN])
		echo "Canceled.";
		;;
	*)
		if [ ! -d temp_all ]; then
			echo "Failed.";
			exit;
		fi;
		echo -e "Replacing all...\c";
		for DIR in `ls temp_all`; do
			if [ ! -d "./$DIR" ]; then
				 mkdir -p "./$DIR";
			fi;
			for SUB_DIR in `ls "temp_all/$DIR"`; do
				if [ -d "./$DIR/$SUB_DIR" ]; then
					 rm -rf "./$DIR/$SUB_DIR";
				fi;
				cp -R "temp_all/$DIR/$SUB_DIR" "./$DIR/";
				echo -e ".\c";
			done;
		done;
		rm -rf temp_all;
		echo "done.";
		;;
esac
