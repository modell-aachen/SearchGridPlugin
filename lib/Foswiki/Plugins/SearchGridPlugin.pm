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

our $searchGridCounter = 0;


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
    if ($Foswiki::cfg{Plugins}{SolrPlugin}{Enabled}) {
      require Foswiki::Plugins::SolrPlugin;
    } else {
      return 0;
    }

    # Register the _EXAMPLETAG function to handle %EXAMPLETAG{...}%
    # This will be called whenever %EXAMPLETAG% or %EXAMPLETAG{...}% is
    # seen in the topic text.
    Foswiki::Func::registerTagHandler( 'SEARCHGRID', \&_searchGrid );

    # Allow a sub to be called from the REST interface
    # using the provided alias
    Foswiki::Func::registerRESTHandler( 'searchproxy',
                                        \&_callSearchProxy,
                                        authenticate => 0,
                                        validate => 0,
                                        http_allow => 'GET,POST',
                                      );

    # Plugin correctly initialized
    $searchGridCounter = 0;
    return 1;
}

sub _searchGrid {
    my($session, $params, $topic, $web, $topicObject) = @_;
    # Params:
    # - DEFAULT: Full text search
    # - FACETS:  List of Facets (e.g. create_date:date,author:user,)
    # - FILTER:  List of Filter (e.g. create_date:date,author:user,)
    # - VIEW: defaultSolr,defaultTable,Eigenes Template
    # - displayRows: list von anzeie mata feldern

    my $defaultQuery = $params->{_DEFAULT};
    my $resultsPerPage = $params->{resultsPerPage} || 20;
    my $headers = $params->{headers} || '';
    my $fields = $params->{fields} || '';
    my $filters = $params->{filters} || '';
    my $sortFields = $params->{sortFields} || '';
    my $initialSort = $params->{initialSort} || '';
    my $filterHeading = $params->{filterHeading} || 'Filter';
    my $facets = $params->{facets} || '';
    my $form = $params->{form} || '';
    my $fieldRestriction = $params->{fieldRestriction} || '';
    my $gridField = $params->{gridField} || '';

    my $prefs = {
        q => $defaultQuery,
        resultsPerPage => $resultsPerPage,
        fields => [],
        filters => [],
        filterHeading => $session->i18n->maketext($filterHeading),
        facets => [],
        language => $session->i18n->language,
        form => $form,
        fieldRestriction => $fieldRestriction,
    };

    if($initialSort){
        my @initialSortArray = (split(/,/,$initialSort));
        $prefs->{initialSort} = {
            field => $initialSortArray[0],
            sort => $initialSortArray[1]
        };
    }

    my @parsedFields = ( $fields =~ /(.*?\(.*?\)),?/g );
    my @parsedSortFields = (split(/,/,$sortFields));
    my $index = 0;

    my $fieldConfigs = _parseCommands($fields);
    # Parse fields
    foreach my $fieldConfig (@$fieldConfigs) {
        my @headers = split(/,/,$headers);
        my $field = {
            sortField => $parsedSortFields[$index]
        };
        if( @headers ){
            $field->{title} = $session->i18n->maketext($headers[$index]);
        }
        $field->{component} = $fieldConfig->{command};

        $field->{params} = $fieldConfig->{params};
        push(@{$prefs->{fields}}, $field);

        $index++;
    }
    # Parse grid field
    if($gridField){
        my $gridField = @{_parseCommands($gridField)}[0];
        $prefs->{gridField} = {
            component => $gridField->{command},
            params => $gridField->{params}
        }
    }
    # Parse filters
    foreach my $filter (@{_parseCommands($filters)}) {
        my $newFilter = {
            component => $filter->{command},
            params => $filter->{params}
        };
        push(@{$prefs->{filters}}, $newFilter);
    }
    # Parse facets
    foreach my $facet (@{_parseCommands($facets)}) {
        @{$facet->{params}}[0] = $session->i18n->maketext(@{$facet->{params}}[0]);
        my $newFacet = {
            component => $facet->{command},
            params => $facet->{params}
        };
        push(@{$prefs->{facets}}, $newFacet);
    }

    #First data fetch per backend.
    $prefs->{result} = _buildQuery($session, $prefs);
    my $jPrefs = to_json($prefs);
    #Fix: $n and $quot are automatically expanded by foswiki and destroy the json.
    #So they are replaced.
    $jPrefs =~ s/(\$n|\$quot)//g;
    Foswiki::Func::addToZone( 'head', 'FONTAWESOME',
        '<link rel="stylesheet" type="text/css" media="all" href="%PUBURLPATH%/%SYSTEMWEB%/FontAwesomeContrib/css/font-awesome.min.css" />');
    Foswiki::Func::addToZone( 'head', 'FLATSKIN_WRAPPED',
        '<link rel="stylesheet" type="text/css" media="all" href="%PUBURLPATH%/%SYSTEMWEB%/FlatSkin/css/flatskin_wrapped.min.css" />');
    Foswiki::Func::addToZone( 'script', 'SEARCHGRIDPREF'. $searchGridCounter++,
        "<script type='text/json'>$jPrefs</script>");
    Foswiki::Func::addToZone( 'script', 'SEARCHGRID',
        "<script type='text/javascript' src='%PUBURL%/%SYSTEMWEB%/SearchGridPlugin/searchGrid.js'></script>","jsi18nCore"
    );
    Foswiki::Plugins::JQueryPlugin::createPlugin('jqp::moment', $session);
    return '%JSI18N{"SearchGridPlugin" id="SearchGrid"}% <grid @update-instance-counter="updateInstanceCounter" :instances="instances"></grid>';
}

# Build query data to fetch first search result in backend.
sub _buildQuery {
    my ($session, $prefs) = @_;
    my %search = (
        q => $prefs->{q},
        start => 0,
        rows => $prefs->{resultsPerPage},
        facet => $prefs->{facets} ? 'true' : 'false',
        form => $prefs->{form},
        fl => $prefs->{fieldRestriction},
        'facet.field' => []
    );
    if($prefs->{initialSort}){
        $search{"sort"} = "".$prefs->{initialSort}->{field}." ".$prefs->{initialSort}->{sort};
    }
    foreach my $filter (@{$prefs->{filters}}) {
        push(@{$search{'facet.field'}}, $filter->{params}[1]) if $filter->{component} eq 'select-filter';
    }
    # Here we create a copy of the search settings
    # before setting the facet limits. This will be reused
    # to query the total facet counts later.
    my %searchCopy = %search;

    foreach my $facet (@{$prefs->{facets}}) {
        my $fieldName  = $facet->{params}[1];
        push(@{$search{'facet.field'}}, $fieldName);
        my $limit;
        if ($facet->{params}[2]){
            $limit = $facet->{params}[2];
        }
        else {
            $limit = -1;
        }
        $search{"f.$fieldName.facet.limit"} = $limit;

    }

    my $searchProxyResult = _searchProxy($session, $prefs->{q}, \%search);

    # We additionally add the total number of characteristics per facet
    # For now we do a separate search for this
    $searchProxyResult->{facetTotalCounts} = {};
    $searchCopy{"rows"} = 0;
    $searchCopy{"form"} = '';
    $searchCopy{"facet.limit"} = -1;

    my $facetCountResult = _searchProxy($session, $prefs->{q}, \%searchCopy);
    $facetCountResult = $facetCountResult->{facet_counts}->{facet_fields};
    foreach my $facet (@{$prefs->{facets}}){
        my $facetName = $facet->{params}[1];
        my @facetArray = @{$facetCountResult->{$facetName}};
        $searchProxyResult->{facetTotalCounts}->{$facetName} = scalar(@facetArray)/2;
    }

    return $searchProxyResult;
}

# REST helper to call real searchProxy
sub _callSearchProxy {
    my $session = shift;
    $session = $Foswiki::Plugins::SESSION unless $session;
    my $query = Foswiki::Func::getCgiQuery() || $session->{request};
    my $json = JSON->new;
    return to_json(_searchProxy($session, undef, $query->{param}));
}

# Input: 'command1(param1,param2),command2(param1,param2)'
# Output: [{command => 'command1', params => [param1,param2]}, {command => 'command2', params => [param1,param2]}]
sub _parseCommands {
    my $input = shift;
    my $result = [];

    foreach my $commandString ($input =~ /\s*(.*?\(.*?\))\s*,?\s*/g) {
        my $commandResult = {};
        my ($command) = $commandString =~ /\s*(.*?)\s*\(/;
        $commandResult->{command} = $command;
        my($params) = $commandString =~ /\(\s*(.*?)\s*\)/;

        my @paramsArray = split(/\s*,\s*/, $params);
        $commandResult->{params} = \@paramsArray;
        push(@$result, $commandResult);
    }
    return $result;
}

sub _searchProxy {
    my ($session, $query, $options) = @_;
    my %opts = %{$options};
    my $json = JSON->new->utf8;
    my $meta = Foswiki::Meta->new($session);

    my $web = $session->{webName};
    my $topic = $session->{topicName};
    #TODO: Extend by Template...
    my %workflowMapping = (
        "NEW" => "New",
        "DISCUSSION" => "Discussion",
        "APPROVED" => "Approved",
        "DRAFT" => "Draft",
        "FORMAL_REVIEW" => "Formal review",
        "FORMAL_REVIEW_DRAFT" => "Formal review draft",
        "CONTENT_REVIEW" => "Content review",
        "CONTENT_REVIEW_DRAFT" => "Content review draft",
        "DISCARDED" => "Discarded",
    );
    return 0 if $opts{'wt'} && $opts{'wt'} ne 'json';

    my $wikiUser = Foswiki::Func::getWikiName();

    unless (Foswiki::Func::isAnAdmin($wikiUser)) { # add ACLs
        push @{$options->{fq}}, " (access_granted:$wikiUser OR access_granted:all)"
    }
    #my $content = Foswiki::Plugins::SolrPlugin::getSearcher($session)->restSOLRPROXY($web, $topic);
    my $searcher = Foswiki::Plugins::SolrPlugin::getSearcher($session);
    my $results = $searcher->solrSearch(undef, \%opts);
    my $content = $results->raw_response;

    $content = $json->decode($content->{_content});
    my %forms;

    foreach my $doc (@{$content->{response}->{docs}}) {
        my %doc = %{$doc};
        if($doc{form}) {
            my ($fweb, $ftopic) = Foswiki::Func::normalizeWebTopicName($doc{web}, $doc{form});
            my $form = "$fweb.$ftopic";
            eval{
                $forms{$form} = Foswiki::Form->new($session, $fweb, $ftopic) unless ($forms{$form});
            };
            next if $@;
            my $fields = $forms{$form}->getFields();
            my %tempDoc = %doc;
            while(my ($key, $value) = each(%tempDoc)) {
                if ($key =~ /^field_([A-Za-z0-9]*)_/ && $key !~ /_dv$/) {
                    my $formField = $forms{$form}->getField($1);
                    next unless $formField && $formField->can('getDisplayValue');
                    my $dsp = $formField->getDisplayValue($doc->{$key});
                    next unless $dsp;
                    $dsp = $meta->expandMacros($dsp);
                    # Add display value to result set.
                    $doc->{$key.'_dv'} = $dsp;
                }
            }
        }
        if ($doc{workflowmeta_name_s}) {
            my $newName = $session->i18n->maketext($workflowMapping{$doc{workflowmeta_name_s}});
            $doc->{workflowmeta_name_s_dv} = $newName;
        }
        for (grep {$doc{$_} =~ /%/ } keys %doc ) {
            $doc{$_} =~ s/&quot;/"/g;
            $doc->{$_} = Foswiki::Func::expandCommonVariables($doc{$_}, $topic, $web, $meta);
        }
    }

    $opts{form} = $opts{form}[0] if ref $opts{form} eq "ARRAY";
    my $formParam = $opts{form} || "";
    $content->{facet_dsps} = {};
    if($formParam){
        my ($fweb,$ftopic) = split(/\./,$formParam);
        my $form = Foswiki::Form->new($session, $fweb, $ftopic);
        my $facetDsps = {};
        while(my ($key, $value) = each(%{$content->{facet_counts}->{facet_fields}})) {
            $key =~ /^field_([A-Za-z0-9]*)_/;
            my $formField = $form->getField($1);
            next unless $formField;
            next unless $formField->can('getDisplayValue');
            my $length = scalar @$value;
            my @array = @$value;
            my $mapping = {};
            $facetDsps->{$key} = $mapping;
            for(my $index = 0; $index < $length; $index += 2){
                my $dsp = $formField->getDisplayValue($array[$index]);
                $mapping->{$array[$index]} = $dsp;
            }
        }
        $content->{facet_dsps} = $facetDsps;
    }
    return $content;
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
