# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::SearchGridPlugin


=cut

package Foswiki::Plugins::SearchGridPlugin;

use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

use JSON;
use version; our $VERSION = version->declare("v0.1");

our $RELEASE = "0.1";

our $SHORTDESCRIPTION = 'Search Gird Plugin for create Solr overviews';


=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean
   * =$topic= - the name of the topic in the current CGI query
   * =$web= - the name of the web in the current CGI query
   * =$user= - the login name of the user
   * =$installWeb= - the name of the web the plugin topic is in
     (usually the same as =$Foswiki::cfg{SystemWebName}=)

*REQUIRED*

Called to initialise the plugin. If everything is OK, should return
a non-zero value. On non-fatal failure, should write a message
using =Foswiki::Func::writeWarning= and return 0. In this case
%<nop>FAILEDPLUGINS% will indicate which plugins failed.

In the case of a catastrophic failure that will prevent the whole
installation from working safely, this handler may use 'die', which
will be trapped and reported in the browser.

__Note:__ Please align macro names with the Plugin name, e.g. if
your Plugin is called !FooBarPlugin, name macros FOOBAR and/or
FOOBARSOMETHING. This avoids namespace issues.

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    if ($Foswiki::cfg{Plugins}{VueJSPlugin}{Enabled}) {
      require Foswiki::Plugins::VueJSPlugin;
    } else {
      return 0;
    }

    # Register the _EXAMPLETAG function to handle %EXAMPLETAG{...}%
    # This will be called whenever %EXAMPLETAG% or %EXAMPLETAG{...}% is
    # seen in the topic text.
    Foswiki::Func::registerTagHandler( 'SEARCHGRID', \&_searchGrid );

    # Allow a sub to be called from the REST interface
    # using the provided alias
    Foswiki::Func::registerRESTHandler( 'example', \&restExample );

    # Plugin correctly initialized
    return 1;
}

sub _searchGrid {
    my($session, $params, $topic, $web, $topicObject) = @_;
    use Data::Dumper;
    # Params:
    # - DEFAULT: Full text search
    # - FACETS:  List of Facets (e.g. create_date:date,author:user,)
    # - FILTER:  List of Filter (e.g. create_date:date,author:user,)
    # - VIEW: defaultSolr,defaultTable,Eigenes Template
    # - displayRows: list von anzeie mata feldern

    my $defaultQuery = $params->{_DEFAULT};
    my $headers = $params->{headers};
    my $fields = $params->{fields};

    my $prefs = {q => $defaultQuery, fields => []};
    my @parsedFields = ( $fields =~ /(.*?\(.*?\)),?/g );
    my $index = 0;
    foreach my $header (split(/,/,$headers)) {
        my $field = {title => $header};
        my $parsedField = @parsedFields[$index];
        my ($component) = $parsedField =~ /(.*?)\(/;
        $field->{component} = $component;
        my($params) = $parsedField =~ /\((.*?)\)/;

        my @paramsArray = split(/,/, $params);
        $field->{params} = \@paramsArray;
        push($prefs->{fields}, $field);

        $index++;
    }
    Foswiki::Func::writeWarning(Dumper($prefs));
    #Foswiki::Plugins::VueJSPlugin::loadDependencies();
    my $jPrefs = to_json($prefs);
    Foswiki::Func::addToZone( 'script', 'SEARCHGRIDPREF',
        "<script type='text/json'>$jPrefs</script>");
    Foswiki::Func::addToZone( 'script', 'SEARCHGRID',
        "<script type='text/javascript' src='%PUBURL%/%SYSTEMWEB%/SearchGridPlugin/searchGrid.js'></script>"
    );
    return "<grid></grid>";
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: %$AUTHOR%

Copyright (C) 2008-2013 Foswiki Contributors. Foswiki Contributors
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
