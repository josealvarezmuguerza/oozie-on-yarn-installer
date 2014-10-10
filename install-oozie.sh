#!/bin/bash

##This script aims to easily install Oozie runing in local hadoop cluster. 
# Prerequisites: Hadoop 2 up & running
#                JDK 6+

## download and extract Oozie 3.3.2

##Define folders and oozie version
##customize these 5 values

##Oozie version you want to install
OOZIE_VERSION=3.3.2
##Installed hadoop version 
MVN_PROFILE_HADOOP_VERSION=hadoop-23
##How Oozie calls your above Hadoop version
OOZIE_HADOOP_VERSION=hadoop-2
##Your hadoop user
HADOOP_USER=jose
##Where you want to install Oozie
export OOZIE_HOME=/home/jose/tools/oozie-$OOZIE_VERSION


LOCAL_DIR=`pwd`
DOWNLOAD_DIR=$LOCAL_DIR/oozie-talball
BUILD_DIR=$DOWNLOAD_DIR/oozie-$OOZIE_VERSION


##Download tarball from repo
mkdir -p $BUILD_DIR
cd $DOWNLOAD_DIR
wget http://archive.apache.org/dist/oozie/$OOZIE_VERSION/oozie-$OOZIE_VERSION.tar.gz
tar xzvf oozie-$OOZIE_VERSION.tar.gz

cd $BUILD_DIR

##Hadoop 2 needs client 2.3.0 + , default 2.0.2 will fail
##        This is required while Oozie supports a a pre 0.23 version of Hadoop which does not have
##        the hadoop-auth artifact. After Oozie phase-out pre 0.23 we can get rid of this property.
OOZIE_HADOOP_DEFAULT_AUTH_VERSION=`xmllint --xpath "(//*[local-name()='hadoop.auth.version']/text())[1]" $BUILD_DIR/pom.xml`
OOZIE_HADOOP_AUTH_VERSION=2.3.0
##update hadoop-client in main pom.xml
sed -i 's/<hadoop.auth.version>'"$OOZIE_HADOOP_DEFAULT_AUTH_VERSION"'<\/hadoop.auth.version>/<hadoop.auth.version>'"$OOZIE_HADOOP_AUTH_VERSION"'<\/hadoop.auth.version>/' $BUILD_DIR/pom.xml 
##update hadoop-client in hadoop 2/hadooplibs  pom.xml
sed -i 's/<version>'"$OOZIE_HADOOP_DEFAULT_AUTH_VERSION"'/<version>'"$OOZIE_HADOOP_AUTH_VERSION"'/' $BUILD_DIR/hadooplibs/hadoop-2/pom.xml 


##compiling
mvn -DskipTests=true -P $MVN_PROFILE_HADOOP_VERSION clean package assembly:single    

##copy bin to OOZIE_HOME
mkdir -p $OOZIE_HOME
cp ${BUILD_DIR}/distro/target/oozie-$OOZIE_VERSION-distro.tar.gz $OOZIE_HOME
cd $OOZIE_HOME
tar xzvf $OOZIE_HOME/oozie-$OOZIE_VERSION-distro.tar.gz -C $OOZIE_HOME/
mv  $OOZIE_HOME/oozie-$OOZIE_VERSION/* $OOZIE_HOME
#this folder should be emplty here 
rm -rf $OOZIE_HOME/oozie-$OOZIE_VERSION

##Copy examples folder
cp -r ${BUILD_DIR}/examples/target/oozie-examples-$OOZIE_VERSION-examples/* $OOZIE_HOME

##Adding libraries
mkdir $OOZIE_HOME/libext
cd $OOZIE_HOME/libext
wget http://extjs.com/deploy/ext-2.2.zip

cp $BUILD_DIR/hadooplibs/$OOZIE_HADOOP_VERSION/target/hadooplibs/hadooplib-$OOZIE_HADOOP_AUTH_VERSION.oozie-$OOZIE_VERSION/* $OOZIE_HOME/libext

##Prepare and deploy oozie war
$OOZIE_HOME/bin/oozie-setup.sh prepare-war


##edit core-site in hadoop 
sed -i 's/<\/configuration>/\n <!-- oozie-->\n  <property>\n    <name>hadoop.proxyuser.'"$HADOOP_USER"'.hosts<\/name>\n    <value>localhost<\/value>\n  <\/property>\n\n  <property>\n    <name>hadoop.proxyuser.'"$HADOOP_USER"'.groups<\/name>\n    <value>'"$HADOOP_USER"'<\/value>\n  <\/property>\n \n<\/configuration>/'  $HADOOP_HOME/etc/hadoop/core-site.xml 


# prepare DB - MySqlServer must be already in place
cd $OOZIE_HOME/bin/
$OOZIE_HOME/bin/ooziedb.sh create -sqlfile oozie.sql -run

# Put required libraries to HDFS
#HDFS=`xmllint --xpath "//configuration/property[name='fs.defaultFS']/value/text()" $HADOOP_HOME/etc/hadoop/core-site.xml`
hdfs dfs -mkdir -p /user/$HADOOP_USER
hdfs dfs -put -f ${BUILD_DIR}/sharelib/target/oozie-sharelib-$OOZIE_VERSION/share /user/$HADOOP_USER


# Run Oozie
$OOZIE_HOME/bin/oozied.sh run
$OOZIE_HOME/bin/oozie admin -oozie http://localhost:11000/oozie -status

