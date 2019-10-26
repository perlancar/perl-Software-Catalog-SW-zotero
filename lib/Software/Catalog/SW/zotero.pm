package Software::Catalog::SW::zotero;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use PerlX::Maybe;
use Software::Catalog::Util qw(extract_from_url);

use Role::Tiny::With;
with 'Versioning::Scheme::Dotted';
with 'Software::Catalog::Role::Software';

sub homepage_url { "https://www.zotero.org/" }

sub latest_version {
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

sub download_url {
    my ($self, %args) = @_;

    my $version = $args{version};
    if (!$version) {
        my $verres = $self->latest_version(arch => $args{arch});
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

sub archive_info {
    my ($self, %args) = @_;
    [200, "OK", {
        programs => [
            {name=>"zotero", path=>"/"},
        ],
    }];
}

1;
# ABSTRACT: Zotero

=for Pod::Coverage ^(.+)$
