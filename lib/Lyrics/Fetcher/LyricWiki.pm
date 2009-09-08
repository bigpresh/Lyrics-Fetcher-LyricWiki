package Lyrics::Fetcher::LyricWiki;

# $Id$

use 5.005000;
use strict;
use warnings;
use SOAP::Lite;
use Carp;

our $VERSION = '0.06';

# the HTTP User-Agent we'll send:
our $AGENT = "Perl/Lyrics::Fetcher::LyricWiki $VERSION";


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

This module tries to get song lyrics from www.lyricwiki.org.  It's designed to
be called by Lyrics::Fetcher, but can be used directly if you'd prefer.


=head1 FUNCTIONS    

=over 4

=item I<fetch>($artist, $song)

Fetch lyrics for the requested song.

=cut

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

    # Check if we got told we couldn't have these lyrics due to licencing
    # restrictions:
    if ($result->{lyrics} =~ /Unfortunately, due to licensing restrictions/) {
        $Lyrics::Fetcher::Error = 
            'No lyrics via API due to Licensing restriction';
        return;
    }
    
    # looks like it worked:
    $Lyrics::Fetcher::Error = 'OK';
    return $result->{lyrics};


}



1;
__END__

=back

=head1 BUGS

Probably.  Coded in about an hour whilst drinking cold lager :)
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

Copyright (C) 2007-2008 by David Precious

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

Legal disclaimer: I have no connection with the owners of www.azlyrics.com.
Lyrics fetched by this script may be copyrighted by the authors, it's up to 
you to determine whether this is the case, and if so, whether you are entitled 
to request/use those lyrics.  You will almost certainly not be allowed to use
the lyrics obtained for any commercial purposes.

=cut
