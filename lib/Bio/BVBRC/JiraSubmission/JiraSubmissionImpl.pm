package Bio::BVBRC::JiraSubmission::JiraSubmissionImpl;
use strict;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

JiraSubmission

=head1 DESCRIPTION



=cut

#BEGIN_HEADER

use Bio::BVBRC::JiraSubmission::Jira;

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}
=head1 METHODS
=head2 submit_bug

  $issue = $obj->submit_bug($summary, $description, $website_version, $webpage_url)

=over 4


=item Parameter and return types

=begin html

<pre>
$summary is a string
$description is a string
$website_version is a string
$webpage_url is a string
$issue is an Issue
Issue is a reference to a hash where the following keys are defined:
	key has a value which is a string
	url has a value which is a string
	status has a value which is a string
</pre>

=end html

=begin text

$summary is a string
$description is a string
$website_version is a string
$webpage_url is a string
$issue is an Issue
Issue is a reference to a hash where the following keys are defined:
	key has a value which is a string
	url has a value which is a string
	status has a value which is a string

=end text



=item Description


=back

=cut

sub submit_bug
{
    my $self = shift;
    my($summary, $description, $website_version, $webpage_url) = @_;

    my @_bad_arguments;
    (!ref($summary)) or push(@_bad_arguments, "Invalid type for argument \"summary\" (value was \"$summary\")");
    (!ref($description)) or push(@_bad_arguments, "Invalid type for argument \"description\" (value was \"$description\")");
    (!ref($website_version)) or push(@_bad_arguments, "Invalid type for argument \"website_version\" (value was \"$website_version\")");
    (!ref($webpage_url)) or push(@_bad_arguments, "Invalid type for argument \"webpage_url\" (value was \"$webpage_url\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to submit_bug:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	die $msg;
    }

    my $ctx = $Bio::BVBRC::JiraSubmission::Service::CallContext;
    my($issue);
    #BEGIN submit_bug

    local $ENV{KB_AUTH_TOKEN} = $ctx->token;
    my $j = Bio::BVBRC::JiraSubmission::Jira->new;
    $issue = $j->submit_bug($summary, $description, $website_version, $webpage_url);

    #END submit_bug
    my @_bad_returns;
    (ref($issue) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"issue\" (value was \"$issue\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to submit_bug:\n" . join("", map { "\t$_\n" } @_bad_returns);
	die $msg;
    }
    return($issue);
}


=head2 submit_task_failure

  $issue = $obj->submit_task_failure($summary, $description, $website_version, $webpage_url, $task_id)

=over 4


=item Parameter and return types

=begin html

<pre>
$summary is a string
$description is a string
$website_version is a string
$webpage_url is a string
$task_id is a string
$issue is an Issue
Issue is a reference to a hash where the following keys are defined:
	key has a value which is a string
	url has a value which is a string
	status has a value which is a string
</pre>

=end html

=begin text

$summary is a string
$description is a string
$website_version is a string
$webpage_url is a string
$task_id is a string
$issue is an Issue
Issue is a reference to a hash where the following keys are defined:
	key has a value which is a string
	url has a value which is a string
	status has a value which is a string

=end text



=item Description


=back

=cut

sub submit_task_failure
{
    my $self = shift;
    my($summary, $description, $website_version, $webpage_url, $task_id) = @_;

    my @_bad_arguments;
    (!ref($summary)) or push(@_bad_arguments, "Invalid type for argument \"summary\" (value was \"$summary\")");
    (!ref($description)) or push(@_bad_arguments, "Invalid type for argument \"description\" (value was \"$description\")");
    (!ref($website_version)) or push(@_bad_arguments, "Invalid type for argument \"website_version\" (value was \"$website_version\")");
    (!ref($webpage_url)) or push(@_bad_arguments, "Invalid type for argument \"webpage_url\" (value was \"$webpage_url\")");
    (!ref($task_id)) or push(@_bad_arguments, "Invalid type for argument \"task_id\" (value was \"$task_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to submit_task_failure:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	die $msg;
    }

    my $ctx = $Bio::BVBRC::JiraSubmission::Service::CallContext;
    my($issue);
    #BEGIN submit_task_failure

    local $ENV{KB_AUTH_TOKEN} = $ctx->token;
    my $j = Bio::BVBRC::JiraSubmission::Jira->new;
    $issue = $j->submit_task_failure($summary, $description, $website_version, $webpage_url, $task_id);

    #END submit_task_failure
    my @_bad_returns;
    (ref($issue) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"issue\" (value was \"$issue\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to submit_task_failure:\n" . join("", map { "\t$_\n" } @_bad_returns);
	die $msg;
    }
    return($issue);
}





=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}



=head1 TYPES



=head2 Issue

=over 4


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
key has a value which is a string
url has a value which is a string
status has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
key has a value which is a string
url has a value which is a string
status has a value which is a string


=end text

=back


=cut

1;
