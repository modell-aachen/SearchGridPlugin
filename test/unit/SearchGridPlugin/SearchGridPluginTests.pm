package SearchGridPluginTests;

use strict;
use warnings;

use ModacUnitTestCase;
our @ISA = qw( ModacUnitTestCase );

use Error qw ( :try );
use Foswiki::Plugins::SearchGridPlugin;
use JSON;

sub new {
    my ($class, @args) = @_;
    my $this = shift()->SUPER::new('SearchGridPluginTests', @args);
    return $this;
}

sub loadExtraConfig {
    my $this = shift;
    $this->SUPER::loadExtraConfig();
    $Foswiki::cfg{Plugins}{SearchGridPlugin}{Enabled} = 1;
    return;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
    return;
}

sub tear_down {
    my $this = shift;

    $this->SUPER::tear_down();
    return;
}

sub test_excelExportIsDisableIfRestrictedFieldsAreNotConfigured {
    my ( $this ) = @_;

    my $frontendData = Foswiki::Plugins::SearchGridPlugin::_generateFrontendData({
        enableExcelExport => 1
    });

    $this->assert($frontendData->{enableExcelExport} eq JSON::false, "Excel export is enabled although field restrictions are not set");

    return;
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: Modell Aachen GmbH

Copyright (C) 2008-2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
