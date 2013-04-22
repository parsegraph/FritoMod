Name: fritomod

# Change all release values back to 1 when bumping to a new version
Version:	1.3
Release:	1%{?dist}
Summary:	Bridge between Lua and C++

Group:		Applications/Internet
License:	MIT
URL:		http://www.fritomod.com
Source0:	fritomod-1.3.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch
Requires:	lua

%description
TODO Add longer description

%prep
%setup -q

%build
./configure /usr

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT
make install DESTDIR=%{buildroot}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%{_datadir}/lua/5.1/*
