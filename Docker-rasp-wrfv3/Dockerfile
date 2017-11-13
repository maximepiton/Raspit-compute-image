FROM fedora:25

ENV BASEDIR=/root/rasp/

RUN mkdir $BASEDIR

# required packages
RUN yum -y update \
  && yum -y install netcdf-fortran libpng15 iproute-tc tcp_wrappers-libs sendmail procmail psmisc procps-ng mailx \
  findutils ImageMagick perl-CPAN ncl netcdf libpng libjpeg-turbo which patch vim less lftp nano python

# configure CPAN and install required modules
RUN (echo y;echo o conf prerequisites_policy follow;echo o conf commit) | cpan \
  && cpan install Proc/Background.pm

# fix dependencies
RUN ln -s libnetcdff.so.6 /lib64/libnetcdff.so.5 \
  && ln -s libnetcdf.so.11 /lib64/libnetcdf.so.7


WORKDIR /root/

#
# Unpack software packages
# Assuming you have downloaded these files from here: http://rasp-uk.uk/SOFTWARE/WRFV3.x/
#
ADD raspGM.tgz $BASEDIR
ADD raspGM-bin.tgz $BASEDIR
ADD rangs.tgz $BASEDIR

# Patch files with fixes
COPY GM-master.pl.patch /root/
RUN cd $BASEDIR/bin \
  && patch GM-master.pl < ~/GM-master.pl.patch \
  && rm ~/GM-master.pl.patch

#
# Set environment for interactive container shells
#
RUN echo export BASEDIR=$BASEDIR >> /etc/bashrc \
  && echo export PATH+=:\$BASEDIR/bin >> /etc/bashrc

#
# gsutil install
#
WORKDIR /root/
RUN curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar zx
ENV PATH "$PATH:/root/gsutil"

# cleanup
RUN yum clean all
RUN rm -rf ~/rasp/GM

CMD ["bash"]
