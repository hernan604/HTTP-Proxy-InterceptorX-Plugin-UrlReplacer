package My::Proxy;
use Test::More;
use Moose;
use lib './t';
use TestsConfig;
use TestServer;
use HTTP::Tiny;
use Data::Printer;
use Path::Class;

extends qw/HTTP::Proxy::Interceptor/;
with qw/
    HTTP::Proxy::InterceptorX::Plugin::UrlReplacer
/;

my $url_path;
my $proxy_port        = 32452;
my $tests_config      = TestsConfig->new();
my $server            = TestServer->new();
   $server->set_dispatch( $tests_config->conteudos );
my $pid_server        = $server->background();
#ok 1;

my $p = My::Proxy->new( urls_to_proxy => {
    $server->root . "/scripts.js" => {
        "url" => $server->root ."/some-other-url.js"
    }
} );

my $pid = fork_proxy( $p );

#User agents
my $ua       = HTTP::Tiny->new( );
my $ua_proxy = HTTP::Tiny->new( proxy => "http://127.0.0.1:$proxy_port" );


#  NORMAL REQUEST (WITHOUT PROXY)
my $res            = $ua->get( $server->root . "/scripts.js");
my $content_wanted = $tests_config->conteudos->{ '/scripts.js' }->{args}->{ content }->{ original };
ok( $res->{ content } eq $content_wanted , "Content is fine" );
ok( $res->{ content } =~ /javascript/gi , "found javascript in the original string" );

#  REQUEST WITH PROXY (CONTENT WILL BE MODIFIED)
my $res_proxy      = $ua_proxy->get( $server->root . "/scripts.js");
ok( $res_proxy->{ content } =~ /BLAAAAAAA/ig , "found BLAAAAA in the modified response. BLAAAA came from another url" );
ok( $res_proxy->{ content } !~ /javascript/ig , "did not find javascript in the modified response" );

#   $url_path       = "/teste.js";
#   $res_proxy      = $ua_proxy->get( $server->root . $url_path );
#   ok( $res_proxy->{ content } eq $tests_config->conteudos->{ $url_path }->{args}->{ content }->{ original } , "Conteudo original2 está ok" );

#warn $res_proxy->{ content };
#warn $tests_config->conteudos->{ '/scripts.js' }->{args}-> content }->{ original };

#agora usando o proxy


#depois dos testes..
kill 'HUP', $pid, $pid_server;



sub fork_proxy {
    my $proxy = shift;
#   my $sub   = shift;
    my $pid = fork;
    die "Unable to fork proxy" if not defined $pid;
    if ( $pid == 0 ) {
        $0 .= " (proxy)";
        # this is the http proxy
        $proxy->run(  port => $proxy_port );
#       $sub->() if ( defined $sub and ref $sub eq 'CODE' );
        exit 0;
    }
    # back to the parent
    return $pid;
}

done_testing;
