package WWW::LiveChat::API;

use 5.006;
use strict;
use warnings;

use Crypt::SSLeay ();
use LWP::UserAgent ();
use URI::Escape 'uri_escape';
use JSON;

=head1 NAME

WWW::LiveChat::API - LiveChat API implementation.

=head1 VERSION

Version 0.0001

=cut

our $VERSION = '0.0001';

# defaults
use constant BASE_URL => 'https://api.livechatinc.com';

=head1 SYNOPSIS

    use WWW::LiveChat::API;

    my $livechat = WWW::LiveChat::API->new(login => 'racke@linuxia.de',
                                           api_key => '46e6822d72b9dcb3d994a06fe1fc2c23');

    $livechat->status();

    $livechat->operators();

=head1 DESCRIPTION

This module is a Perl interface to the LiveChat API as defined at

L<< http://www.livechatinc.com/api/ >>.

=head1 CONSTRUCTOR

=head2 new

Create a WWW::LiveChat::API object with the following parameters:

=over 4

=item login

Your LiveChat login (required).

=item api_key

Your LiveChat API key (required). This can be retrieved from
the control panel (My profile => LiveChat API key).

=item timezone.

Your timezone, e.g. Europe/Vienna.

=cut

sub new {
	my ($class, $self);

	$class = shift;
	$self = {@_};
	bless $self, $class;
}

=head1 METHODS

=head2 status

    $lc_api->status()

returns chat status.

    $lc_api->status(1)

returns chat status for a particular skill.

Possible return values are: online, offline, callback or expired.

This is documented at L<< http://www.livechatinc.com/api/status/ >>.

=cut

sub status {
    my ($self, $id) = @_;

    $result = $self->_build_function('status');

    return $result;
}

=head2 operators

    $lc_api->operators()

returns list of operators.

    $lc_api->operators(44)

returns detailed information about an operator, which
contains timezone and email in addition to the values
in operators list.

    $lc_api->operators(undef, {login => 'chatta',
                               password => 'nevairbe',
                               name => 'Chat Doe'})

creates an operator and returns operator information.

    $lc_api->operators(44, undef)

deletes an operator.

This is documented at L<< http://www.livechatinc.com/api/operators/ >>.

=cut

sub operators {
	my ($self, $id, $data_ref) = @_;
	my ($result);

	$result = $self->_build_function('operators', $id, $data_ref);

	return $result;			
}

sub skills {
	my ($self, $id, $data_ref) = @_;
	my ($result);

	$result = $self->_build_function('skills', $id, $data_ref);

	return $result;	
}

=head2 request

=cut
	
sub request {
	my ($self, $function, $method, $params) = @_;
	my ($url, @url_frags, $request, $response, $result, $json_return);

	# compose URL
	@url_frags = (BASE_URL, $function);
	
	if ($method eq 'DELETE') {
		if (defined $params->{id}) {
			push (@url_frags, $params->{id});
		}
		$json_return = 0;
	}
	elsif ($method eq 'GET' || $method eq 'PUT') {
		if (defined $params->{id}) {
			push (@url_frags, $params->{id});
		}
		$json_return = 1;
	}
	else {
		$json_return = 1;
	}

	$url = join('/', @url_frags);
	
	$self->{ua} ||= LWP::UserAgent->new(agent => "perl-WWW-LiveChat-API/$VERSION");

	# prepare request
	$request = HTTP::Request->new($method => $url);
    $request->authorization_basic($self->{login}, $self->{api_key});
	
    if (ref($params) eq 'HASH' && keys %$params ) {
        $request->content_type( 'application/x-www-form-urlencoded' );
        $request->content( $self->_build_content( $params ) );
    }

	$response = $self->{ua}->request($request);

	if ($response->code eq '200') {
		# request successful
		if ($json_return) {
			# parsing content as JSON
			$result = $self->_parse_json(\$response->content);
		}
		else {
			$result = 1;
		}
		
		return $result;
	}
	else {
		print $request->as_string;
		die 'LiveChat-API request failed (' . $response->code . '): '
			. $response->message;
	}
}

sub call_function {
	my ($self, $function, $id, $data_ref) = @_;
	my ($result, %data);
	
	if (@_ == 2) {
		# return list
		$result = $self->request($function, 'GET');
	}
	elsif (@_ == 3) {
		# detailed information
		$result = $self->request($function, 'GET', {id => $id});
	}
	elsif (@_ == 4) {
		if ($id) {
			if (defined $data_ref) {
				# update
				%data = %$data_ref;
				$data{id} = $id;
				$result = $self->request($function, 'PUT', \%data);
			}
			else {
				# delete
				$result = $self->request($function, 'DELETE', {id => $id});
			}
		}
		else {
			# create
			%data = %$data_ref;
			$data{id} = $id;
			$result = $self->request($function, 'POST', \%data);
		}
	}

	return $result;
}

sub _build_content {
	my ($self, $params) = @_;
	my (@args, $frag);
	
	for my $key (keys %$params) {
#		next if $key eq 'id';
		
		$frag = uri_escape($key) . '=';
		
		if (defined $params->{$key}) {
			$frag .= uri_escape($params->{$key});
		}
		
        push @args, $frag;
    }

    return join('&', @args) || '';
}

sub _parse_json {
	my ($self, $json_ref) = @_;
	my ($json_struct);
	
	$json_struct = from_json($$json_ref);

	return $json_struct;
}

=head1 AUTHOR

Stefan Hornburg (Racke), C<< <racke at linuxia.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-livechat-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-LiveChat-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::LiveChat::API


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-LiveChat-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-LiveChat-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-LiveChat-API>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-LiveChat-API/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::LiveChat::API
