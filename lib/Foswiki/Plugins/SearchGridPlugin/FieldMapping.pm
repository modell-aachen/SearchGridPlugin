package Foswiki::Plugins::SearchGridPlugin::FieldMapping;

use strict;
use warnings;

use Foswiki::Plugins::SearchGridPlugin;


my $fieldMapping = {
    'text' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
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
        sort => 'field_%Name%_s',
        params => ['field_%Name%_s_dv', 'field_%Name%_s'],
        fieldRestriction => 'field_%Name%_s',
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
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_lst'],
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
    'select+multi' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_lst'], 
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
    'select2+multi' => {
        sort => 'field_%Name%_sort',
        params => ['field_%Name%_lst'],
        fieldRestriction => 'field_%Name%_lst',
        command => 'list-field',
    },
};

sub getFieldMapping{
    my $type = shift;
    my $name = shift;
    my $mapping = $fieldMapping->{$type};
    return _replaceNameHash($mapping,$name);
}
sub _replaceNameHash{
    my $arr = shift;
    my $name = shift;
    my $ret = {};

    foreach my $key (keys $arr){
        my $value = $arr->{$key};
        if(ref($value) eq 'ARRAY'){
            $value = _replaceNameArr($value,$name);
        }elsif(ref $value eq ref {}){
            $value = _replaceNameHash($value,$name);
        }else{
            $value =~ s/%Name%/$name/;
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
        }elsif(ref $value eq ref {}){
            $value = _replaceNameHash($value,$name);
        }else{
            $value =~ s/%Name%/$name/;
        }
        push @ret, $value;
    }
    return \@ret;
}

1;

