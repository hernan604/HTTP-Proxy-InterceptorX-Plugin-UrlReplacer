package TestsConfig;
use Moose;
use File::Slurp;
use Path::Class;

has conteudos => (
    is => 'ro',
    default => sub {
        return 
        {
            "/scripts.js" => {
                
                ref     => \&html_content,
                args    => {
                    content => {
                        original => <<SCRIPT
alert( "javascript original content" );
SCRIPT
                    }
                
                }
            },
            "/some-other-url.js" => {
                ref     => \&html_content,
                args    => {
                    content => {
                        original => <<SCRIPT
alert( "BLAAAAAAAAAAAAAAAA" );
SCRIPT
                
                        ,altered => <<SCRIPT
var altered_content = "other content";
SCRIPT
                    }
                }
            }
        };
    }
); 

sub html_content {
    my ( $cgi, $url_path, $args ) = @_;
    return if !ref $cgi;
    print
        $cgi->header(),
        (   defined $args 
        and exists $args->{ content } 
        and exists $args->{ content }->{ original } )
        ? $args->{ content }->{ original } : ""
}


1;
