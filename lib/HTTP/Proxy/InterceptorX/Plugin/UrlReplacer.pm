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

#   use DDP; warn p $res->headers->as_string;
    $self->override_content( $res->content ) if $res->is_success || $res->is_redirect;
    $self->override_headers( $res->headers ) if $res->is_success || $res->is_redirect;

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

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer - replaces response content from another url

=head1 SYNOPSIS

    package My::Custom::Proxy;
    use Moose;
    extends qw/HTTP::Proxy::Interceptor/;
    with qw/
      HTTP::Proxy::InterceptorX::Plugin::UrlReplacer
    /;

    1;

    my $p = My::Custom::Proxy->new(
      config_path => 'teste_config.pl', #dont really need this for this plugin
      port        => 9919,
    );

    $p->start ;
    1;

=head1 CONFIG

create a config_file.pl with:

    {
        "http://www.site1.com.br/" => {
          UrlReplacer => "http://www.site2.com.br/"
        },
        "http://www.somesite.com.br/" => {
          UrlReplacer => "http://www.othersite.com.br/"
        },
    }

and start the proxy.

=head1 DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer allows you to trick the browser by replacing the content from a url with content from another url.

=head1 AUTHOR

Hernan Lopes E<lt>hernan@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Hernan Lopes

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
