package Lyrics::Fetcher::LyricWiki;

# $Id$

use 5.008007;
use strict;
use warnings;
use SOAP::Lite;
use Carp;

our $VERSION = '0.01';

# the HTTP User-Agent we'll send:
our $AGENT = "Perl/Lyrics::Fetcher::LyricWiki $VERSION";

    

sub fetch {
    
    my $self = shift;
    my ( $artist, $song ) = @_;
    
    # reset the error var, change it if an error occurs.
    $Lyrics::Fetcher::Error = 'OK';
    
    unless ($artist && $song) {
        carp($Lyrics::Fetcher::Error = 
            'fetch() called without artist and song');
        return;
    }
    
    my $soap = new SOAP::Lite->service('http://lyricwiki.org/server.php?wsdl');
    my $result = $soap->getSong($artist, $song);
        
    
    unless ($result->{lyrics}) {
        $Lyrics::Fetcher::Error = 'SOAP request failed';
        return;
    }
    
    if ($result->{lyrics} eq 'Not found') {
        $Lyrics::Fetcher::Error = 
                'Lyrics not found';
            return;
    }
    
    # looks like it worked:
    $Lyrics::Fetcher::Error = 'OK';
    return $result->{lyrics};


}


sub parse {
    
    my $html = shift;
    my $tp = HTML::TokeParser->new(\$html);
    #my $text = $tp->get_trimmed_text();
    
    
    # the HTML on the pages returned by azlyrics.com is rather nasty, so we
    # have to do dirty tricks to parse it.  We'll find all <font> tags, and read
    # from there until the </font> tag.  If what we got looks vaguely suitable,
    # we then need to trim it a little.
    while (my $wotsit = $tp->get_tag('font')) {
        
        # get the text up to the next </font> tag
        my $text = $tp->get_text('/font');
        
        if (length $text > 20) {
            # this might well be it.  We'll clean it up and do some checks on
            # it in the process.
            
            $text =~ s/\r//mg;
            
            # the page title should look like "<ARTIST> LYRICS" on a line
            # by itself:
            unless ($text =~ s/^.*LYRICS \n?//xgs) {
                carp("No page title found, this HTML doesn't look right");
                return;
            }
           
            
            unless ($text =~ s/\[ \s www\.azlyrics\.com \s \]//xmg) {
                carp("No azlyrics.com line found");
                return;
            }
            
            # song title should be on a line that starts and ends with double
            # quotes, strip it out
            unless ($text =~ s/" .+ "//xmg) {
                carp("No song title found, this HTML doesn't look right");
                return;
            }
            
            # some lyrics pages have credits at the bottom for the submitter...
            # remove them from the lyrics, but store them in case they're
            # wanted:
            my @credits;
            while ($text =~ s{\[ Thanks \s to \s (.+) \]}{}xgi) {
                push @credits, $1;
            }
            
            # bodge... do this twice, to avoid the '... used only once' warning
            @Lyrics::Fetcher::azcredits = @credits;
            @Lyrics::Fetcher::azcredits = @credits;
            
            # finally, clear up excess blank lines:
            while ($text =~ s/\n{2,}/\n/gs) {};

            
            
            return $text;
            
        }
        
    
    
    }
    
} # end of sub parse



1;
__END__

=head1 NAME

Lyrics::Fetcher::LyricWiki - Get song lyrics from www.LyricWiki.org

=head1 SYNOPSIS

  use Lyrics::Fetcher;
  print Lyrics::Fetcher->fetch("<artist>","<song>","LyricWiki");

  # or, if you want to use this module directly without Lyrics::Fetcher's
  # involvement:
  use Lyrics::Fetcher::LyricWiki;
  print Lyrics::Fetcher::LyricWiki->fetch('<artist>', '<song>');


=head1 DESCRIPTION

This module tries to get song lyrics from www.azlyrics.com.  It's designed to
be called by Lyrics::Fetcher, but can be used directly if you'd prefer.


=head1 BUGS

Probably.  Coded in about an hour whilst drinking a cold can of Fosters :)
If you find any bugs, please let me know.


=head1 THANKS

Thanks to Sean Colombo for creating www.LyricWiki.org, and for creating
SOAP-based web services to fetch lyrics (that's *so* much nicer than having
to screen-scrape them!).


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.


=head1 AUTHOR

David Precious E<lt>davidp@preshweb.co.ukE<gt>



=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by David Precious

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

Legal disclaimer: I have no connection with the owners of www.azlyrics.com.
Lyrics fetched by this script may be copyrighted by the authors, it's up to 
you to determine whether this is the case, and if so, whether you are entitled 
to request/use those lyrics.  You will almost certainly not be allowed to use
the lyrics obtained for any commercial purposes.

=cut
