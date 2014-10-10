oozie-at-yarn-installer
=======================

single script for installing Oozie Workflow Scheduler in local based on Hadoop Yarn.

###Requirements

- Hadoop Yarn (running)
- JDK 6+

![image](http://oozie.apache.org/images/oozie_200x.png)

###HOW-TO

```java
git clone git@github.com:josealvarezmuguerza/oozie-at-yarn-installer.git
cd oozie-at-yarn-installer
```

Open install-oozie.sh in your preferred editor and set the following parameters as desired:

```java
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
```

The above configuration belongs to Oozie v3.3.2 against Hadoop 2.3, and my hadoop's user is 'jose'. You should be able to set other versions here, but always over Hadoop Yarn. 

This script will let your Oozie up & running, so, after it runs you can open it at http://localhost:11000/oozie

enjoy it!

##License
Apache License, Version 2.0 http://www.apache.org/licenses/LICENSE-2.0
