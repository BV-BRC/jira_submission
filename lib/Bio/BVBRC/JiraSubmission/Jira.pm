package Bio::BVBRC::JiraSubmission::Jira;

use strict;
use REST::Client;
use JSON::XS;
use Bio::BVBRC::JiraSubmission::Config qw(:all);
use Bio::KBase::AppService::AppConfig qw(app_service_url);
use Data::Dumper;
use MIME::Base64;
use P3UserAPI;
use Bio::KBase::AppService::SchedulerDB;

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw(rest json));


=head1 NAME

Bio::BVBRC::JiraSubmission::Jira - Utility routines for talking to Jira

=head1 DESCRIPTION

This module talks to the Jira Service Management instance for BV-BRC.

It is configured with the username and API token as well as the
base URL of the REST endpoint.

Issues are submitted using the identity held in the currently-active
authentication token.

=cut

sub new
{
    my($class) = @_;

    my $rest = REST::Client->new();
    $rest->setHost(jira_endpoint);
    my $auth = "Basic " . encode_base64(jira_user . ":" . jira_api_token);
    $rest->addHeader("Authorization", $auth);
    $rest->addHeader("X-ExperimentalApi", "opt-in");

    my $self = {
	rest => $rest,
	json => JSON::XS->new->pretty->canonical,
    };
    return bless $self, $class;
}

sub submit_bug
{
    my($self, $summary, $description, $website_version, $webpage) = @_;

    my($tag, $userid, $on_behalf) = $self->determine_submitter();

    my @userid_field;

    @userid_field = (jira_fields->{username} => $userid) if $userid;;

    my $issue = {
	serviceDeskId => jira_servicedesk,
	requestTypeId => jira_bug_request,
	requestFieldValues => {
	    jira_fields->{summary} => $summary,
	    jira_fields->{description} => $description,
	    jira_fields->{website_version} => $website_version,
	    jira_fields->{webpage} => $webpage,
	    @userid_field
	},
	@$on_behalf,
    };
    my $issue_txt = $self->json->encode($issue);
    print STDERR "$issue_txt\n";

    $self->rest->POST("/servicedeskapi/request", $issue_txt,
		     { "Content-Type" => "application/json" });
    if ($self->rest->responseCode !~ /^2/)
    {
	warn "Issue submission failed: " . $self->rest->responseCode() . " " . $self->rest->responseContent() . "\n";
	print Dumper($self->rest);
	return undef;
    }
    else
    {
	my $txt = $self->rest->responseContent();
	my $dat = eval { $self->json->decode($txt); };
	if ($@)
	{
	    warn "Could not parse response\n";
	    return undef;
	}
	
	return {
	    key => $dat->{issueKey},
	    url => $dat->{_links}->{web},
	    status => $dat->{currentStatus}->{status},
	};
    }
}

sub determine_submitter
{
    my($self) = @_;

    my $tag;
    my @on_behalf;
    my $token = P3AuthToken->new(ignore_authrc => 1);
    print Dumper(TOKEN => $token, \%ENV);
    my $userid;
    if (!$token || !$token->is_token())
    {
	$tag = "(Ticket posted without attribution: No authentication token available to verify submitting user)\n";
    }
    else
    {
	$userid = $token->user_id;
	my $short_userid = $userid;
	$short_userid =~ s/\@(patricbrc\.org|bvbrc)$//;
        my $user = eval { P3UserAPI->new->get_user($short_userid); };
	
	if ($user)
	{
	    @on_behalf = (raiseOnBehalfOf => $user->{email});
	}
	else
	{
	    warn "User lookup failed: $@" if $@;
	    $tag = "(Ticket posted without attribution: Could not look up BV-BRC user $userid)\n";
	}
    }
    return($tag, $userid, \@on_behalf);
}

sub submit_task_failure
{
    my($self, $summary, $description, $website_version, $webpage, $task_id) = @_;

    my $db = Bio::KBase::AppService::SchedulerDB->new();

    my($tag, $userid, $on_behalf) = $self->determine_submitter();

    my $task_info = $db->retrieve_task_details_jira($task_id, $userid);
    print STDERR Dumper($task_id, $userid, $task_info);

    my @userid_field;
    @userid_field = (jira_fields->{username} => $userid) if $userid;;

    my $issue = {
	serviceDeskId => jira_servicedesk,
	requestTypeId => jira_task_fail_request,
	requestFieldValues => {
	    jira_fields->{summary} => $summary,
	    jira_fields->{description} => $description,
	    jira_fields->{website_version} => $website_version,
	    jira_fields->{webpage} => $webpage,
	    @userid_field,
	},
	@$on_behalf,
    };

    my $fv = $issue->{requestFieldValues};

    while (my($k, $v) = each %$task_info)
    {
	$fv->{jira_fields->{$k}} = $v if defined($v);
    }

    $fv->{jira_fields->{task_stdout}} = app_service_url . "/task_info/$task_id/stdout";
    $fv->{jira_fields->{task_stdout}} = app_service_url . "/task_info/$task_id/stdout";
    $fv->{jira_fields->{task_stderr}} = app_service_url . "/task_info/$task_id/stderr";
    $fv->{jira_fields->{parameters}} = '{noformat}' . $fv->{jira_fields->{parameters}} . '{noformat}';

    my $issue_txt = $self->json->encode($issue);
    print STDERR "$issue_txt\n";

    $self->rest->POST("/servicedeskapi/request", $issue_txt,
		     { "Content-Type" => "application/json" });
    if ($self->rest->responseCode !~ /^2/)
    {
	warn "Issue submission failed: " . $self->rest->responseCode() . " " . $self->rest->responseContent() . "\n";
	# print Dumper($self->rest);
	return undef;
    }
    else
    {
	my $txt = $self->rest->responseContent();
	my $dat = eval { $self->json->decode($txt); };
	# if ($dat)
	# {
	#     print "Resp: " . Dumper($dat);
	# }

	if ($@)
	{
	    warn "Could not parse response\n";
	    return undef;
	}
	
	return {
	    key => $dat->{issueKey},
	    url => $dat->{_links}->{web},
	    status => $dat->{currentStatus}->{status},
	};
    }
}

sub desk_url
{
    my($self, $to_append) = @_;
    return join("/", jira_endpoint, "servicedesk", jira_servicedesk, $to_append);
}


1;
