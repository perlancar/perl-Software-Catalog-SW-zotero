package Software::Catalog::SW::zotero;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use PerlX::Maybe;
use Software::Catalog::Util qw(extract_from_url);

use Role::Tiny::With;
with 'Software::Catalog::Role::Software';
#with 'Software::Catalog::Role::VersionScheme::SemVer';

our %SPEC;

sub meta {
    return {
        homepage_url => "https://www.zotero.org/",
    };
}

$SPEC{get_latest_version} = {
    v => 1.1,
    is_meth => 1,
    args => {
        arch => { schema=>'software::arch*', req=>1 },
    },
};
sub get_latest_version {
    my ($self, %args) = @_;

    my $carch = $args{arch};
    return [400, "Please specify arch"] unless $carch;

    my $narch = $self->_canon2native_arch($carch);

    extract_from_url(
        url => "https://www.zotero.org/download/",
        re  => qr!"standaloneVersions".+"\Q$narch\E":"([^"]+)"!,
    );
}

sub canon2native_arch_map {
    return +{
        # XXX mac
        'linux-x86' => 'linux-i686',
        'linux-x86_64' => 'linux-x86_64',
        'win32' => 'win32',
    },
}

$SPEC{get_latest_version} = {
    v => 1.1,
    is_meth => 1,
    args => {
        version => { schema=>'software::version*' },
        arch => { schema=>'software::arch*', req=>1 },
    },
};
sub get_download_url {
    my ($self, %args) = @_;

    my $version = $args{version};
    if (!$version) {
        my $verres = $self->get_latest_version(arch => $args{arch});
        return [500, "Can't get latest version: $verres->[0] - $verres->[1]"]
            unless $verres->[0] == 200;
        $version = $verres->[2];
    }

    my $narch = $self->_canon2native_arch($args{arch});

    [200, "OK",
     join(
         "",
         "https://www.zotero.org/download/client/dl?channel=release&platform=$narch&version=$version",
     ), {
         'func.version' => $version,
     }];
}

sub get_programs {
    my ($self, %args) = @_;
    [200, "OK", [
        {name=>"zotero", path=>"/"},
    ]];
}

1;
# ABSTRACT: Zcoin desktop GUI client

=for Pod::Coverage ^(.+)$
