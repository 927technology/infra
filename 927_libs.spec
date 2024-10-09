Name:           927_libs
Version:        0.0.1
Release:        1%{?dist}
Summary:        Library for 927 Scripts
BuildArch:      noarch

License:        GPLv2
Source0:        %{name}-%{version}.tar.gz

Requires:       bash jq osquery

%description
BASH libraries for 927 Technology scripts

%prep
%setup -q

%files
%{_libdir}/927/osquery.f