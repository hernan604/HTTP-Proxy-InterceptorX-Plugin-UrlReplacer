package HTTP::Proxy::InterceptorX::Plugin::UrlReplacer;

use strict;
use 5.008_005;
our $VERSION = '0.01';
use Moose::Role;
use URI;
use Data::Printer;

=head2

Permite mapear uma url em outra url.. ou seja, quando seu browser tentar abrir uma url,

ele vai pensar que está abrindo essa url mas na verdade o conteúdo que o browser receber terá 

vindo da outra url que você mapeou.

=cut

sub UrlReplacer {
  my ( $self, $args ) = @_; 
  if (
        defined $self->http_request &&
        exists $self->urls_to_proxy->{ $self->http_request->{ _uri }->as_string } && 
        exists $self->urls_to_proxy->{ $self->http_request->{ _uri }->as_string }->{ UrlReplacer } ) {
    my $nova_url = 
        URI->new( $self->urls_to_proxy->{ $self->http_request->{ _uri }->as_string }->{ UrlReplacer } );
    if ( exists $self->urls_to_proxy->{ $self->http_request->{ _uri }->as_string }->{ use_random_var } 
             && $self->urls_to_proxy->{ $self->http_request->{ _uri }->as_string }->{ use_random_var } ) {
        $nova_url->query_param( "var".int(rand(99999999)) => int(rand(99999999)));
    }
    warn "  INTERCEPTED => " , $nova_url->as_string , "\n";
    my $req = HTTP::Request->new( $self->http_request->method => $nova_url->as_string );
    my $res = $self->ua->request( $req );
    $self->content( $res->content ) if $res->is_success || $res->is_redirect;

    return 0;
  }
}

after 'BUILD'=>sub {
    my ( $self ) = @_; 
    $self->append_plugin_method( "UrlReplacer" );
};


1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer - Blah blah blah

=head1 SYNOPSIS

  use HTTP::Proxy::InterceptorX::Plugin::UrlReplacer;

=head1 DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer is

=head1 AUTHOR

Hernan Lopes E<lt>hernan@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Hernan Lopes

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
