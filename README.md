## 

Permite mapear uma url em outra url.. ou seja, quando seu browser tentar abrir uma url,

ele vai pensar que está abrindo essa url mas na verdade o conteúdo que o browser receber terá

vindo da outra url que você mapeou.

# NAME

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer - replaces response content from another url

# SYNOPSIS

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

# CONFIG

create a config\_file.pl with:

    {
        "http://www.site1.com.br/" => {
          UrlReplacer => "http://www.site2.com.br/"
        },
        "http://www.somesite.com.br/" => {
          UrlReplacer => "http://www.othersite.com.br/"
        },
    }

and start the proxy.

# DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::UrlReplacer allows you to trick the browser by replacing the content from a url with content from another url.

# AUTHOR

Hernan Lopes <hernan@cpan.org>

# COPYRIGHT

Copyright 2013- Hernan Lopes

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
