#docker pull newcrawler/spider
#docker pull registry.aliyuncs.com/speed/newcrawler

FROM centos:centos7  
MAINTAINER Speed <https://github.com/speed/newcrawler>

#install.sh
#jetty https://www.eclipse.org/jetty/download.html
#jre http://www.oracle.com/technetwork/java/javase/downloads/index.html
ENV jetty="https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.27.v20200227/jetty-distribution-9.4.27.v20200227.tar.gz"
#ENV jre="http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/server-jre-8u172-linux-x64.tar.gz"
ENV jre="https://github.com/speed/newcrawler-dependency/raw/master/jdk8u172/server-jre-8u172-linux-x64.tar.gz"

USER root

RUN yum -y install wget tar git sed sudo

#========================================
# Add normal user with passwordless sudo
#======================================== 
RUN sudo useradd ncuser --shell /bin/bash --create-home \
  && sudo usermod -a -G wheel ncuser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'ncuser:secret' | chpasswd

RUN git clone https://github.com/speed/newcrawler.git /home/ncuser/newcrawler

RUN sed -ie 's/jdbc:hsqldb:file:~\/newcrawler\/db\/spider/jdbc:hsqldb:file:\/home\/ncuser\/newcrawler\/db\/spider/g' /home/ncuser/newcrawler/war/WEB-INF/classes/datanucleus.properties

RUN cd /home/ncuser/newcrawler; mkdir ./db

#jetty
RUN cd /home/ncuser/newcrawler; wget --no-check-certificate $jetty -O jetty.tar.gz
RUN cd /home/ncuser/newcrawler; mkdir ./jetty && tar -xzvf jetty.tar.gz -C ./jetty --strip-components 1


#jre
RUN cd /home/ncuser/newcrawler; wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $jre -O server-jre-linux.tar.gz
RUN cd /home/ncuser/newcrawler; mkdir ./jre && tar -xzvf server-jre-linux.tar.gz -C ./jre --strip-components 1

#PhantomJs
#RUN yum -y install bzip2
#RUN yum -y install fontconfig freetype libfreetype.so.6 libfontconfig.so.1

#Script and Config
RUN cd /home/ncuser/newcrawler; wget --no-check-certificate https://github.com/speed/windows-64bit-jetty-jre/raw/master/jetty/webapps/newcrawler.xml -P jetty/webapps/ -O jetty/webapps/newcrawler.xml
RUN cd /home/ncuser/newcrawler; wget --no-check-certificate https://github.com/speed/newcrawler/raw/master/start-docker.sh -O start.sh
RUN cd /home/ncuser/newcrawler; wget --no-check-certificate https://github.com/speed/newcrawler/raw/master/stop.sh -O stop.sh

RUN mkdir /opt/selenium; wget --no-verbose -O /opt/selenium/ModHeader.crx https://raw.githubusercontent.com/speed/newcrawler-plugin-urlfetch-chrome/master/crx/ModHeader.crx\
    && chmod 755 /opt/selenium/ModHeader.crx

#Remove install package
RUN cd /home/ncuser/newcrawler; rm -f -v jetty.tar.gz
RUN cd /home/ncuser/newcrawler; rm -f -v server-jre-linux.tar.gz
RUN cd /home/ncuser/newcrawler; rm -f -v install_*.sh
RUN cd /home/ncuser/newcrawler; rm -f -v Dockerfile

RUN echo 'Congratulations, the installation is successful.'

RUN chmod -R a+rwx /home/ncuser/newcrawler
RUN chown -R ncuser:ncuser /home/ncuser/newcrawler

USER ncuser

EXPOSE 8500

CMD cd /home/ncuser/newcrawler; /bin/bash -C 'start.sh';/bin/bash

RUN echo 'Startup is successful.'

