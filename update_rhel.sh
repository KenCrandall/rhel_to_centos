if [ -z "$1" ]; then
echo "Please specify the centos version"
exit
fi

if grep -i centos /etc/issue; then
echo "Box is already CentOS"
exit
fi

RELEASE=$1
AUTOREBOOT="false"
MIRROR="mirror.centos.org"
ARCH="x86_64"
VER=`echo "$RELEASE" '>='6 | bc -l`
if [ $VER -eq 1 ]
then
    echo "CENTOS $RELEASE"
    OSDIR="Packages"
    MAINRELEASE="6"
    Packages=('centos-release' 'yum' 'yum-utils' 'yum-plugin-fastestmirror')
elif [ $VER -eq 0 ] 
then
    echo "CENTOS $RELEASE"
    OSDIR="CentOS"
    MAINRELEASE="5"
    declare -a Packages=('centos-release' 'centos-release-notes' 'yum' 'yum-utils' 'yum-updatesd' 'yum-fastestmirror');
fi
wget  http://$MIRROR/centos/$RELEASE/os/$ARCH/$OSDIR/
wget  http://$MIRROR/centos/$RELEASE/os/$ARCH/RPM-GPG-KEY-CentOS-$MAINRELEASE

for package in "${Packages[@]}"
do
    full_package=`grep ${package} index.html  | grep -o ">${package}-[0-9].*rpm" | sed 's/>//'`
    wget http://$MIRROR/centos/$RELEASE/os/$ARCH/$OSDIR/$full_package
done

rpm --import RPM-GPG-KEY-CentOS-$RELEASE

if [ "$MAINRELEASE" -eq "6" ]; then
rpm -e --nodeps redhat-release-server
rpm -e yum-rhn-plugin rhn-check rhnsd rhn-setup
rpm -Uhv --force *.rpm
yum -y upgrade
rpm -e --nodeps redhat-release-server
yum -y remove yum-rhn-plugin
elif [ "$MAINRELEASE" -eq "5" ]; then
rpm -e --nodeps redhat-release
rpm -e yum-rhn-plugin
rpm -Uvh --force *.rpm
yum -y remove rhn-client-tools
yum -y upgrade
fi

if [ "$AUTOREBOOT" = "true" ]; then
    reboot
fi
