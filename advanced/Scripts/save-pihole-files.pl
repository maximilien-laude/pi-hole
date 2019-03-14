#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;

my $save_dir = "/root/saves";
my $pihole_config_tar_gz = "/root/saves/pihole-configs.tar.gz";
my $pihole_system_tar_gz = "/root/saves/pihole-system.tar.gz";
my $pihole_number_words = "/var/lib/pihole-system/etc/pihole/totals-domains.txt";
my $pihole_white_list = "/var/lib/pihole-system/etc/pihole/blacklist.txt";
my $pihole_black_list = "/var/lib/pihole-system/etc/pihole/whitelist.txt";
my $pihole_regex_list = "/var/lib/pihole-system/etc/pihole/regex.list";

sub total_words {

        my $a = shift;
        open(FILE, "<$a");
        my $words = "0";
        while (<FILE>) {

                $words++;

        }
        close(FILE);
        return $words;
}

sub file_content {

       my $filename = shift;
       my $content = read_file($filename);
       $content =~ s/^\s+|\s+$//g ;
       return $content;

}

sub save_total {

	my $file_to_write = shift;
	my $total_increment = "0";
	my $list;
	my $pihole_white_list = shift;
	my $pihole_black_list = shift;
	my $pihole_regex_list = shift;
	my @pihole_lists_wb = ( $pihole_white_list , $pihole_black_list , $pihole_regex_list );
	
	foreach $list ( @pihole_lists_wb  ) {

		my $total = total_words("$list");
       		$total_increment += $total ;
				
    	}

    	open(my $fw, '>', "$file_to_write" );
	print $fw "$total_increment";
    	close $fw;

}

if ( ! -d $save_dir ) {

	mkdir $save_dir, 0600;

}

####################################
######### pihole-system	############
####################################

if ( ! -e $pihole_system_tar_gz ){

	system("tar -zcf $pihole_system_tar_gz -C /var/lib/pihole-system --exclude='/var/lib/pihole-system/etc/pihole' .");

}

####################################
######### pihole-config ############
####################################

if ( ! -e $pihole_config_tar_gz ){
	
    system("tar -zcf $pihole_config_tar_gz -C /var/lib/pihole-system/etc/pihole .");
	
}

elsif ( -e $pihole_config_tar_gz ){

	if ( -e $pihole_black_list && -e $pihole_white_list && -e $pihole_regex_list ){

		my $pihole_number_words_save="/var/lib/pihole-system/etc/pihole/totals-domains-saved.txt";
		my $pihole_number_words_testing="/tmp/totals-domains-testing.txt";	
			
		if( ! -e $pihole_number_words_save ){
		
			unlink $pihole_config_tar_gz;		
			save_total($pihole_number_words_save,$pihole_white_list,$pihole_black_list,$pihole_regex_list);

		}
		
		else {
		
			my $saved_domains_count = file_content($pihole_number_words_save);
			save_total($pihole_number_words_testing,$pihole_white_list,$pihole_black_list,$pihole_regex_list);                     
			my $testing_domains_count = file_content($pihole_number_words_testing);

			if ( $saved_domains_count != $testing_domains_count ) {
							
				unlink $pihole_config_tar_gz ;
				unlink $pihole_number_words_save;
                		open(my $fw, '>', "$pihole_number_words_save");
				print $fw "$testing_domains_count";
                		close $fw;
				
			}
			
			else {
			
				exit 0
			
			}			
						
		}
		
		system("tar -zcf $pihole_config_tar_gz -C /var/lib/pihole-system/etc/pihole .");
		exit 0
				
	}

	else {
	
		die "no pihole lists can't save";
		
	}	
	 
}
