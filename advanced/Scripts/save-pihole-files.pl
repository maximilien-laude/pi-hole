#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;

my $save_dir = "/root/saves";
my $pihole_config_tar_gz = "/root/saves/pihole-configs.tar.gz";
my $pihole_system_tar_gz = "/root/saves/pihole-system.tar.gz";
my $pihole_number_words = "/var/lib/pihole-system/etc/pihole/totals-domains.txt";
my $pihole_white_list = '/var/lib/pihole-system/etc/pihole/blacklist.txt';
my $pihole_black_list = '/var/lib/pihole-system/etc/pihole/whitelist.txt';
my $pihole_regex_list = '/var/lib/pihole-system/etc/pihole/regex.list';

sub total_words {

	my $pihole_number_words_testing = shift ;
	my $pihole_list_w = shift ;
	my $pihole_list_b = shift ;
	my $pihole_list_rx = shift ;

	my @pihole_lists_wb = ( $pihole_list_w , $pihole_list_b , $pihole_list_rx );
        my $total=`wc -l @pihole_lists_wb | tail -n1 `;
        $total =~ s/^\s+|\s+$//g;
	$total =~ s/total//;        
	$total =~ s/^\s+|\s+$//g;
       	open(my $fw, '>', $pihole_number_words_testing );
        print $fw "$total\n";
        close $fw;;

}

sub file_content {

       my $filename = shift;
       my $content = read_file($filename);
       return $content;

}



if ( ! -d $save_dir ) {

	mkdir $save_dir, 0755;

}

####################################
######### pihole-system	############
####################################

if ( ! -e $pihole_system_tar_gz ){

	system("tar -zcf $pihole_system_tar_gz --exclude='/var/lib/pihole-system/etc/pihole' /var/lib/pihole-system/ ");

}

####################################
######### pihole-config ############
####################################



if ( ! -e $pihole_config_tar_gz ){
	
        system("tar -zcf $pihole_config_tar_gz /var/lib/pihole-system/etc/pihole");
	
}

elsif ( -e $pihole_config_tar_gz ){

	if ( -e $pihole_black_list && -e $pihole_white_list && -e $pihole_regex_list ){

		my $pihole_number_words_save="/var/lib/pihole-system/etc/pihole/totals-domains-saved.txt";
		my $pihole_number_words_testing="/tmp/totals-domains-testing.txt";	
	
		if( ! -e $pihole_number_words_save ){
		
			unlink $pihole_config_tar_gz ;
			total_words($pihole_number_words_save , $pihole_white_list , $pihole_black_list , $pihole_regex_list );
		
		}
		
		else {
		
			total_words($pihole_number_words_testing , $pihole_white_list , $pihole_black_list , $pihole_regex_list );
			
			my $saved_domains_count = file_content($pihole_number_words_save);
			my $testing_domains_count = file_content($pihole_number_words_testing);
			
			if ( $saved_domains_count != $testing_domains_count ) {
			
				unlink $pihole_config_tar_gz ;
                                total_words($pihole_number_words_save , $pihole_white_list , $pihole_black_list , $pihole_regex_list );

			}
			
			else {
			
				exit 0
			
			}			
						
		}
		
		system("tar -zcf $pihole_config_tar_gz /var/lib/pihole-system/etc/pihole");
		exit 0
				
	}


	else {
	
		exit 0
	
	}	
	 
}
