# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::SearchGridPlugin


=cut

package Foswiki::Plugins::SearchGridPlugin;

use strict;
use warnings;
use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
use Digest::MD5 qw(md5_hex);
use JSON;
use version; our $VERSION = version->declare("v0.1");

use Foswiki::Plugins::SearchGridPlugin::FieldMapping;

our $RELEASE = "0.1";

our $SHORTDESCRIPTION = 'Search Gird Plugin for create Solr overviews';

our $searchGridCounter = 0;

our $NO_PREFS_IN_TOPIC = 1;

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

sub maintenanceHandler {
  Foswiki::Plugins::MaintenancePlugin::registerCheck("SearchGridPlugin:Prevent glossar in the grid", {
    name => "Prevent glossar entries in the grid",
    description => "Disable the glossar in Search Grids.",
    check => sub {
      my $isGlossaryEnabled = $Foswiki::cfg{Plugins}{GlossarPlugin}{Enabled};
      unless($isGlossaryEnabled){
        return { result => 0 };
      }
      my $config = $Foswiki::cfg{Extensions}{GlossarPlugin}{ExcludeSelector} || '';
      if($config =~ m#(?:^|,)\s*\.SearchGridContainer\s*(?:$|,)#) { # this check is best effort, but should be ok
        return { result => 0 };
      } else {
        my $excludeSelector = $config && $config =~ m/\S/ ? "$config,.SearchGridContainer" : '.SearchGridContainer';
        return {
          result => 1,
          priority => $Foswiki::Plugins::MaintenancePlugin::ERROR,
          solution => "Please add '.SearchGridContainer' to {Extensions}{GlossarPlugin}{ExcludeSelector} in configure.<verbatim>{Extensions}{GlossarPlugin}{ExcludeSelector} = \"$excludeSelector\"</verbatim>"
        }
      }
    }
  });

  Foswiki::Plugins::MaintenancePlugin::registerCheck("SearchGridPlugin:Invalid form field names", {
    name => "Invalid form field names",
    description => "Form fields may only contain latin alpha-numeric characters and underscore",
    check => sub {
      my @forms = split("\n", $Foswiki::Plugins::SESSION->search->searchWeb(
        name => '*',
        topic => '*Form',
        web => 'all',
        type => 'query',
        format => '$web.$topic',
        separator => "\n",
        nonoise => 1,
      ));

      my @offenders = ();
      foreach my $formWebTopic (@forms) {
        my ($web, $topic) = Foswiki::Func::normalizeWebTopicName(undef, $formWebTopic);

        my $form = new Foswiki::Form($Foswiki::Plugins::SESSION, $web, $topic);
        foreach my $field (@{$form->getFields}) {
          next unless $field;
          my $name = $field->{name};
          next unless $name && $name =~ s#([^a-zA-Z0-9_])#%RED%<b>$1</b>%ENDCOLOR%#g;
          push @offenders, "<li>field '$name' in the form [[$web.$topic][$web.$topic]].</li>";
        }
      }

      return { result => 0 } unless scalar @offenders;

      unshift @offenders, 'Please remove any non-alphanumeric or underscore characters (a-zA-Z0-9_) from the following fields:<ul>';
      push @offenders, "</ul>";
      return {
        result => 1,
        priority => $Foswiki::Plugins::MaintenancePlugin::ERROR,
        solution => join('', @offenders),
      }
    }
  });
}

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

    Foswiki::Func::registerRESTHandler( 'initialResultSet',
                                        \&_restInitialResultSet,
                                        authenticate => 0,
                                        validate => 0,
                                        http_allow => 'POST',
                                        );

    # Plugin correctly initialized
    $searchGridCounter = 0;
    return 1;
}

sub _filterWikiTags {
  my($text) = @_;
  my @tags = ("noautolink","verbatim","literal");
  foreach (@tags) {
    $text =~ s/<\/?$_>//g
  }
  return $text;
}

sub _searchGrid {
    my($session, $params, $topic, $web, $topicObject) = @_;
    # Params:
    # - DEFAULT: Full text search
    # - FACETS:  List of Facets (e.g. create_date:date,author:user,)
    # - FILTER:  List of Filter (e.g. create_date:date,author:user,)
    # - VIEW: defaultSolr,defaultTable,Eigenes Template
    # - displayRows: list von anzeie mata feldern
    # - wizard: wizard will be displayed if no result or no entry is given

    my $frontendPrefs = _generateFrontendData($params);
    my $prefId = md5_hex(rand);
    my $prefSelector = "SEARCHGRIDPREF_$prefId";
    my $jsonPrefs = to_json($frontendPrefs);
    $jsonPrefs = _filterWikiTags($jsonPrefs);
    $jsonPrefs = MIME::Base64::encode_base64(Encode::encode_utf8($jsonPrefs));
    Foswiki::Func::expandCommonVariables("%VUE{VERSION=\"2\"}%");
    Foswiki::Func::addToZone( 'script', $prefSelector,
        "<script type='text/json'>$jsonPrefs</script>");
    
    #This empty script remains because it funcions as a dependency
    #for other plugins that extend the SearchGrid with custom components
    #e.g. InternalProjectsContrib.
    Foswiki::Func::addToZone( 'script', 'SEARCHGRID',
        "<script></script>","jsi18nCore,VUEJSPLUGIN"
    );
    if($Foswiki::cfg{Plugins}{EmployeesAppPlugin}{Enabled}){
        Foswiki::Plugins::EmployeesAppPlugin::loadJavaScripts($session);
    }

    my $vueClientToken = Foswiki::Plugins::VueJSPlugin::getClientToken();
    return "%JSI18N{\"SearchGridPlugin\" id=\"SearchGrid\"}%<div class=\"SearchGridContainer\" data-vue-client-token=\"$vueClientToken\"><grid preferences-selector='$prefSelector'></grid></div>";
}

sub _generateFrontendData {
    my $params = shift;
    my $session = $Foswiki::Plugins::SESSION;
    my $defaultQuery = $params->{_DEFAULT};
    my $resultsPerPage = $params->{resultsPerPage} || 20;
    my $hasLiveFilter = (defined $params->{hasLiveFilter} && $params->{hasLiveFilter} eq '0') ? JSON::false : JSON::true;
    my $initialHideColumn = (defined $params->{initialHideColumn} && $params->{initialHideColumn} eq '1') ? JSON::true : JSON::false;
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
    my $addons = $params->{addons} || '';
    my $wizardNoResults = $params->{wizardNoResults} || '';
    my $wizardNoEntries = $params->{wizardNoEntries} || '';
    my $enableExcelExport = JSON::false;
    if($fieldRestriction && $params->{enableExcelExport}){
        $enableExcelExport = JSON::true;
    }
    my $includeDeletedDocuments = (defined $params->{includeDeletedDocuments} && $params->{includeDeletedDocuments} eq '1') ? JSON::true : JSON::false;

    my $frontendPrefs = {
        q => $defaultQuery,
        resultsPerPage => $resultsPerPage,
        fields => [],
        filters => [],
        filterHeading => $session->i18n->maketext($filterHeading),
        facets => [],
        initialFacetting => 0,
        initialFiltering => 0,
        form => $form,
        fieldRestriction => $fieldRestriction,
        hasLiveFilter => $hasLiveFilter,
        initialHideColumn => $initialHideColumn,
        enableExcelExport => $enableExcelExport,
        wizardConfig => {},
        includeDeletedDocuments => $includeDeletedDocuments
    };

    my $wizardNoEntriesConfig = _parseCommands($wizardNoEntries)->[0];
    $frontendPrefs->{wizardNoEntriesConfig} = {
        component => $wizardNoEntriesConfig->{command},
        params => $wizardNoEntriesConfig->{params}
    };
    my $wizardNoResultsConfig = _parseCommands($wizardNoResults)->[0];
    $frontendPrefs->{wizardNoResultsConfig} = {
        component => $wizardNoResultsConfig->{command},
        params => $wizardNoResultsConfig->{params}
    };


    my @addonlist = split(/,/,$addons);
    $frontendPrefs->{addons} = \@addonlist;

    if($initialSort){
        my @sortFieldToMap = $initialSort =~ m/\((.*?)\)/g;
        foreach my $sortField (@sortFieldToMap){
            my $mapping = _getFieldMapping($form, $sortField);
            $initialSort =~ s/\($sortField\)/$mapping->{sort}/g;
        }
        $initialSort =~ s/,/ /g;
        $initialSort =~ s/;/,/g;
        $frontendPrefs->{initialSort} = $initialSort;
    }

    my @parsedFields = ( $fields =~ /(.*?\(.*?\)),?/g );
    my @parsedSortFields = (split(/,/,$sortFields));
    my $index = 0;

    #set default fieldRestrictions
    if($frontendPrefs->{fieldRestriction}) {
        my %values = map { $_ => 1 } (split(',', $frontendPrefs->{fieldRestriction}), 'web', 'topic', 'form');
        $frontendPrefs->{fieldRestriction} = join(',', keys %values);
    }

    my $fieldConfigs = _parseCommands($fields, $form);
    # Parse fields
    foreach my $fieldConfig (@$fieldConfigs) {
        my @headers = map{_toDisplayString($_)} split(/,/, _escapeBackslashes($headers));
        my $field = {};
        if($fieldConfig->{sort}){
            $field->{sortField} = $fieldConfig->{sort};
        }
        #override sort from sortfields params
        $field->{sortField} = $parsedSortFields[$index] if $parsedSortFields[$index];

        #get Header from form
        if($form && !$fieldConfig->{title}){
            my ($fWeb, $fTopic) = Foswiki::Func::normalizeWebTopicName("",$form);
            my $formObj = Foswiki::Form->new($session, $fWeb, $fTopic);
            my $formField = $formObj->getField($fieldConfig->{name});
            $field->{title} = Foswiki::Func::expandCommonVariables($formField->{description});
        } else {
            $field->{title} = $fieldConfig->{title};
        }
        if($frontendPrefs->{fieldRestriction} && $fieldConfig->{fieldRestriction}) {
            $frontendPrefs->{fieldRestriction} .= ",".$fieldConfig->{fieldRestriction};
        }

        #override header in headers field
        my $header = $headers[$index];
        $field->{title} = ( defined $header && $header ne '' ) ? $session->i18n->maketext($header) : $field->{title};

        $field->{component} = $fieldConfig->{command};

        $field->{params} = $fieldConfig->{params};
        push(@{$frontendPrefs->{fields}}, $field);

        $index++;
    }

    # Parse grid field
    if($gridField){
        my $gridField = @{_parseCommands($gridField)}[0];
        $frontendPrefs->{gridField} = {
            component => $gridField->{command},
            params => $gridField->{params}
        }
    }
    # Parse filters
    foreach my $filter (@{_parseCommands($filters,$form,'filter')}) {
        @{$filter->{params}}[0] = $session->i18n->maketext(@{$filter->{params}}[0]);
        if(@{$filter->{params}}[2] and $filter->{command} eq 'select-filter') {
            $frontendPrefs->{initialFiltering} = 1;
        }
        my $newFilter = {
            component => $filter->{command},
            params => $filter->{params}
        };
        push(@{$frontendPrefs->{filters}}, $newFilter);
    }
    # Parse facets
    foreach my $facet (@{_parseCommands($facets,$form,'facet')}) {
        @{$facet->{params}}[0] = $session->i18n->maketext(@{$facet->{params}}[0]);
        if(@{$facet->{params}}[3]) {
            $frontendPrefs->{initialFacetting} = 1;
        }
        my $newFacet = {
            component => $facet->{command},
            params => $facet->{params}
        };
        push(@{$frontendPrefs->{facets}}, $newFacet);
    }

    #Parse mappings
    my $mappings = {};
    grep {
        if($_ =~ /^mappings_(.*)$/){
            my $mappedField = $1;
            $mappings->{$mappedField} = {};
            foreach my $mapping (split(";", $params->{$_})){
                $mapping =~ /(.*)=(.*)/;
                $mappings->{$mappedField}->{$1} = Foswiki::Func::expandCommonVariables($2);
            }
        }
    } keys %$params;

    $frontendPrefs->{mappings} = $mappings;

    $frontendPrefs->{result} = _getInitialResultSet($session, $frontendPrefs);

    return $frontendPrefs;

}

sub _restInitialResultSet {
    my ($session) = @_;
    my $request = Foswiki::Func::getRequestObject();
    my $config = from_json($request->param('config'));
    return to_json(_getInitialResultSet($session, $config));
}

sub _getInitialResultSet {
    my ($session, $prefs) = @_;
    my %search = (
        q => $prefs->{q},
        start => 0,
        rows => $prefs->{resultsPerPage},
        facet => $prefs->{facets} ? 'true' : 'false',
        fl => $prefs->{fieldRestriction},
        form => $prefs->{form},
        includeDeletedDocuments => [$prefs->{includeDeletedDocuments}],
        'facet.mincount' => 1,
        'facet.field' => [],
        'facet.missing' => 'on',
        'facet.sort' => 'count',
        'facet.limit' => -1
    );

    if($prefs->{initialSort}) {
        $search{'sort'} = $prefs->{initialSort};
    }

    foreach my $filter (@{$prefs->{filters}}) {
        push(@{$search{'facet.field'}}, "{!ex=$filter->{params}[1]}$filter->{params}[1]") if $filter->{component} eq 'select-filter';
    }

    # Here we create a copy of the search settings
    # before setting the facet limits. This will be reused
    # to query the total facet counts later.
    my %searchCopy = %search;

    foreach my $facet (@{$prefs->{facets}}) {
        my $fieldName  = $facet->{params}[1];
        push(@{$search{'facet.field'}}, "{!ex=$fieldName}$fieldName");
        my $limit;
        if ($facet->{params}[2]){
            $limit = $facet->{params}[2];
        }
        else {
            $limit = -1;
        }
        $search{"f.$fieldName.facet.limit"} = $limit;

    }

    # If initial facet/filter values have been provided, we configure the
    # search criteria accordingly.
    if($prefs->{initialFacetting}) {
        foreach my $facet (@{$prefs->{facets}}) {
            # Check if facet has initial configuration
            if($facet->{params}[3]) {
                my @initialValues = split(/;/, $facet->{params}[3]);
                foreach my $v (@initialValues) {
                    $v = join("\\ ", split(/\s/, $v));
                }
                my $filterQuery = "{!tag=$facet->{params}[1]\ q.op=OR}$facet->{params}[1]:(" . join(" ", @initialValues) . ")";
                push(@{$search{"fq"}}, $filterQuery);
            }
        }
    }
    if($prefs->{initialFiltering} && $prefs->{filters}) {
        foreach my $filter (@{$prefs->{filters}}) {
            # Check if initial filter value has been provided (select-filter only)
            if($filter->{params}[2] and $filter->{component} eq 'select-filter') {
                push(@{$search{"fq"}}, "{!tag=$filter->{params}[1]\ q.op=OR}$filter->{params}[1]:($filter->{params}[2])");
            }
        }
    }

    my $searchProxyResult = _searchProxy($session, $prefs->{q}, \%search);

    # We additionally add the total number of characteristics per facet
    # For now we do a separate search for this
    $searchProxyResult->{facetTotalCounts} = {};
    $searchCopy{"rows"} = 0;
    $searchCopy{"form"} = '';
    $searchCopy{"facet.limit"} = -1;
    $searchCopy{"facet.missing"} = 'on';
    $searchCopy{"facet.sort"} = 'index'; # put 'undef' (aka. __none__) at the bottom

    my $facetCountResult = _searchProxy($session, $prefs->{q}, \%searchCopy);
    $facetCountResult = $facetCountResult->{facet_counts}->{facet_fields};
    foreach my $facet (@{$prefs->{facets}}){
        my $facetName = $facet->{params}[1];
        my $facetArray = $facetCountResult->{$facetName};
        $searchProxyResult->{facetTotalCounts}->{$facetName} = scalar(@$facetArray)/2;

        # see if the unassigned key has a count and remove otherwise
        if((!defined $facetArray->[scalar @$facetArray - 2]) && !$facetArray->[scalar @$facetArray - 1]) {
            $searchProxyResult->{facetTotalCounts}->{$facetName}--;
        }

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

sub _getFieldMapping {
    my ($form,$field) = @_;
    my $session = $Foswiki::Plugins::SESSION;
    my ($fWeb, $fTopic) = Foswiki::Func::normalizeWebTopicName("",$form);
    my $formObj = Foswiki::Form->new($session, $fWeb, $fTopic);
    my $formField = $formObj->getField($field);
    my $mapping;
    if($formField){
        $mapping = Foswiki::Plugins::SearchGridPlugin::FieldMapping::getFieldMapping($formField->{type},$formField->{name});
    } else {
        $mapping = Foswiki::Plugins::SearchGridPlugin::FieldMapping::getStaticFieldMapping($field);
    }
    return $mapping;
}

sub _escapeBackslashes {
    my ($string) = @_;
    $string =~ s#\\\\#\$backslash#g;
    $string =~ s#\\,#\$comma#g;
    $string =~ s#\\\(#\$oparenthesis#g;
    $string =~ s#\\\)#\$cparenthesis#g;
    $string =~ s#\\=#\$equals#g;
    $string =~ s#\\;#\$semicolon#g;
    return $string;
}

sub _toDisplayString {
    my ($string) = @_;
    $string =~ s#\$backslash#\\#g;
    $string =~ s#\$oparenthesis#(#g;
    $string =~ s#\$cparenthesis#)#g;
    $string =~ s#\$equals#=#g;
    $string =~ s#\$semicolon#;#g;
    $string = Foswiki::Func::decodeFormatTokens($string);
    return $string;
}

sub _parseCommands {
    my $input = shift;
    my $form = shift;
    my $type = shift || 'fields';
    my $result = [];

    $input = _escapeBackslashes($input);

    foreach my $commandString ($input =~ /\s*(.*?\(.*?\))\s*,?\s*/g) {

        my ($command) = $commandString =~ /\s*(.*?)\s*\(/;

        my($params) = $commandString =~ /\(\s*(.*?)\s*\)/;
        my @paramsArray = split(/\s*,\s*/, $params);
        @paramsArray = map{_toDisplayString($_)} @paramsArray;

        if ($type =~ m/filter/) {
            push(@$result, _processFilterCommands($command,$form,\@paramsArray));
        } elsif ($type =~ m/facet/) {
            push(@$result, _processFacetCommands($command,$form,\@paramsArray));
        } else {
            push(@$result, _processFieldCommands($command,$form,\@paramsArray));
        }
    }
    return $result;
}

# Input: 'command1(param1,param2),command2(param1,param2)'
# Short (if form is given): '(FieldName1),(FieldName2)'
# Output: [{command => 'command1', params => [param1,param2]}, {command => 'command2', params => [param1,param2]}]
sub _processFieldCommands{
    my $command = shift;
    my $form = shift;
    my $paramsArray = shift;

    my $commandResult = {};
    $commandResult->{command} = $command;
    $commandResult->{params} = \@$paramsArray;
    $commandResult->{name} = $commandResult->{params}[0];

    if($form && !$command && $commandResult->{params}[0]){
        my $mapping = _getFieldMapping($form, $commandResult->{params}[0]);
        if($commandResult->{params} && $commandResult->{params}[1] && $commandResult->{params}[1] =~ /link/) {
            $mapping->{command} = 'url-field';
            my $linkTarget = $commandResult->{params}[1] =~ /link[(.*)]/;
            $mapping->{params}[1] = $linkTarget || 'webtopic';
            $mapping->{fieldRestriction} .= ',';
            $mapping->{fieldRestriction} .= $linkTarget || 'webtopic';
        }
        $commandResult->{title} = $mapping->{title} if $mapping->{title};
        $commandResult->{command} = $mapping->{command};
        $commandResult->{sort} = $mapping->{sort};
        $commandResult->{params} = $mapping->{params};
        $commandResult->{fieldRestriction} = $mapping->{fieldRestriction};
    }
    return $commandResult;
}

# Input: 'multi-select(title,solrField,number,initialValues...)'
# Short  (if form is given): '(facetType,title,FieldName,Number,initialValues...)'
# Output: [{command => 'command1', params => [param1,param2]}, {command => 'command2', params => [param1,param2]}]
sub _processFacetCommands {
    my $command = shift;
    my $form = shift;
    my $paramsArray = shift;
    my $commandResult = {};

    if($form && !$command){
        $commandResult->{command} = shift @$paramsArray;
        my $mapping = _getFieldMapping($form, @$paramsArray[1]);
        @$paramsArray[1] = $mapping->{facet};
        $commandResult->{params} = \@$paramsArray;
    }else{
        $commandResult->{command} = $command;
        $commandResult->{params} = $paramsArray;
    }
    return $commandResult;
}


# Input: 'full-text-filter(header,param1,param2,...)'
# Short for full-text-filter (if form is given): '(header,FieldName1,FieldName2)'
# Output: [{command => 'command1', params => [param1,param2]}, {command => 'command2', params => [param1,param2]}]
sub _processFilterCommands {
    my $command = shift;
    my $form = shift;
    my $paramsArray = shift;

    my $commandResult = {};

    if($form && !$command){
        # default filter
        $commandResult->{command} = "full-text-filter";
        my @autoParamsArray = ();
        my $header = shift @$paramsArray;
        push (@autoParamsArray, $header);
        foreach my $param (@$paramsArray) {
            my $mapping = _getFieldMapping($form, $param);
            push (@autoParamsArray, $mapping->{search});
        }
        $commandResult->{params} = \@autoParamsArray;
    }else{
        $commandResult->{command} = $command;
        $commandResult->{params} = $paramsArray;
    }
    return $commandResult;
}

sub _searchProxy {
    my ($session, $query, $options) = @_;
    my %opts = %{$options};
    $opts{form} = $opts{form}[0] if ref $opts{form} eq "ARRAY";
    my $formParam = $opts{form} || "";
    delete $opts{form};
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
        push @{$opts{fq}}, " (access_granted:$wikiUser OR access_granted:all)"
    }

    $opts{'facet.mincount'} = 1 unless $opts{'facet.mincount'} && $opts{'facet.mincount'} > 0;

    my $searcher = Foswiki::Plugins::SolrPlugin::getSearcher($session);
    my $results = $searcher->solrSearch(undef, \%opts);
    return {status => 'error', msg => 'Can\'t connect to solr.', details => $results->raw_response->{_content}} unless $results->raw_response->{_rc} =~ /200/;

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
                if ($key =~ /^field_([A-Za-z0-9_]*)_/ && $key !~ /_dv(?:_(?:s|lst|msearch))?$/) {
                    my $formField = $forms{$form}->getField($1);
                    next unless $formField && $formField->can('getDisplayValue');

                    my $dsp;
                    if(ref($doc->{$key}) eq 'ARRAY'){
                        $dsp = [];
                        foreach my $value (@{$doc->{$key}}){
                            push(@$dsp, $meta->expandMacros($formField->getDisplayValue($value)));
                        }
                    }
                    else{
                        $dsp = $formField->getDisplayValue($doc->{$key});
                        $dsp = $meta->expandMacros($dsp);
                    }
                    next unless $dsp;
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

    $content->{facet_dsps} = {};
    if($formParam){
        my ($fweb,$ftopic) = split(/\./,$formParam);
        my $form = Foswiki::Form->new($session, $fweb, $ftopic);
        my $facetDsps = {};
        while(my ($key, $value) = each(%{$content->{facet_counts}->{facet_fields}})) {
            next if $key =~ m/_dv(?:_(?:s|lst|msearch))?$/;
            $key =~ /^field_([A-Za-z0-9_]*)_/;
            next unless defined $1;
            my $formField = $form->getField($1);
            next unless $formField;
            next unless $formField->can('getDisplayValue');
            my $length = scalar @$value;
            my @array = @$value;
            my $mapping = {};
            $facetDsps->{$key} = $mapping;
            for(my $index = 0; $index < $length; $index += 2){
                next unless defined $array[$index]; # set to empty
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
