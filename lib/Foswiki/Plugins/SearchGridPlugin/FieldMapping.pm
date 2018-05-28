package Foswiki::Plugins::SearchGridPlugin::FieldMapping;

use strict;
use warnings;

use Foswiki::Plugins::SearchGridPlugin;


my %staticFieldMapping = (
    "workflowmeta_lastprocessor_static_state_new_s" => {
        sort => 'workflowmeta_lastprocessor_static_state_new_dv_s',
        params => ['workflowmeta_lastprocessor_static_state_new_dv_s', 'workflowmeta_lastprocessor_static_state_new_s'],
        fieldRestriction => 'workflowmeta_lastprocessor_static_state_new_dv_s,workflowmeta_lastprocessor_static_state_new_s',
        command => 'user-field',
        title => 'Creator'
    },
    "author" => {
        sort => 'author_s',
        params => ['author_s', 'author'],
        fieldRestriction => 'author_s, author',
        command => 'user-field',
        title => 'Author'
    },
    "title" => {
        sort => 'title_search',
        params => ['title'],
        fieldRestriction => 'title',
        command => 'text-field',
        title => 'Title'
    },
    "lastEdited" => {
        sort => 'workflowmeta_lasttime_currentstate_dt',
        params => ['workflowmeta_lasttime_currentstate_dt'],
        fieldRestriction => 'workflowmeta_lasttime_currentstate_dt',
        command => 'date-field',
        title => 'lasttime edited'
    },
    "createDate" => {
        sort => 'createdate',
        params => ['createdate'],
        fieldRestriction => 'createdate',
        command => 'date-field',
        title => 'Created'
    },
    "workflowState" => {
        sort => 'workflowstate_displayname_s',
        params => ['workflowstate_displayname_s'],
        fieldRestriction => 'workflowstate_displayname_s',
        command => 'text-field',
        title => 'State'
    },
);
my $fieldMapping = {
    'text' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'editor' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_s', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'integer' => {
        sort => 'field_%Name%_i',
        params => ['field_%Name%_i', 'field_%Name%_i'],
        fieldRestriction => 'field_%Name%_i',
        command => 'text-field',
    },
    'date' => {
        sort => 'field_%Name%_dt',
        params => ['field_%Name%_dt'],
        fieldRestriction => 'field_%Name%_dt',
        command => 'date-field',
    },
    'date2' => {
        sort => 'field_%Name%_dt',
        params => ['field_%Name%_dt', ''],
        fieldRestriction => 'field_%Name%_dt',
        command => 'date-field',
    },
    'user' => {
        sort => 'field_%Name%_dv_s',
        params => ['field_%Name%_dv_s', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s,field_%Name%_dv_s',
        command => 'user-field',
    },
    'acl' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'select' => {
        sort => 'field_%Name%_s',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'select+values' => {
        sort => 'field_%Name%_s',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'select2' => {
        sort => 'field_%Name%_s',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'user+multi' => {
        sort => 'none',
        params => ['field_%Name%_dv_s'],
        fieldRestriction => 'field_%Name%_dv_s',
        command => 'text-field',
    },
    'user+group+multi' => {
        sort => 'none',
        params => ['field_%Name%_dv_s'],
        fieldRestriction => 'field_%Name%_dv_s',
        command => 'text-field',
    },
    'user+grouponly' => {
        sort => 'field_%Name%_dv_s',
        params => ['field_%Name%_dv_s'],
        fieldRestriction => 'field_%Name%_dv_s',
        command => 'text-field',
    },
    'user+grouponly+multi' => {
        sort => 'none',
        params => ['field_%Name%_dv_s'],
        fieldRestriction => 'field_%Name%_s',
        command => 'text-field',
    },
    'select+multi' => {
        sort => 'none',
        params => ['field_%Name%_lst'],
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
    'select2+multi' => {
        sort => 'none',
        params => ['field_%Name%_lst'],
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
    'select2+values+integer' => {
        sort => 'field_%Name%_i',
        params => ['field_%Name%_lst'],
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
};

sub getFieldMapping{
    my $type = shift;
    my $name = shift;
    my $mapping = $fieldMapping->{$type};
    return _replaceNameHash($mapping,$name) if $mapping;
    return;
}
sub getStaticFieldMapping{
    my $id = shift;
    return %staticFieldMapping{$id};
}
sub _replaceNameHash{
    my $arr = shift;
    my $name = shift;
    my $ret = {};

    foreach my $key (keys %$arr){
        my $value = $arr->{$key};
        if(ref($value) eq 'ARRAY'){
            $value = _replaceNameArr($value,$name);
        }elsif(ref($value) eq 'HASH'){
            $value = _replaceNameHash($value,$name);
        }else{
            $value =~ s/%Name%/$name/g;
        }
        $ret->{$key} = $value;
    }
    return $ret;
}
sub _replaceNameArr{
    my $arr = shift;
    my $name = shift;
    my @ret = ();

    foreach my $value (@$arr){
        if(ref($value) eq 'ARRAY'){
            $value = _replaceNameArr($value,$name);
        }elsif(ref($value) eq 'HASH'){
            $value = _replaceNameHash($value,$name);
        }else{
            $value =~ s/%Name%/$name/g;
        }
        push @ret, $value;
    }
    return \@ret;
}

1;

