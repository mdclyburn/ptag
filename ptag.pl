#!/usr/bin/perl -w

# ptag - Write psuedo-tags for files in a directory.
#
# Usage: ptag command
#
#        ptag tag <file> tag,tag,tag,tag
#

die "Unrecognized command. Please use 'ptag help'\n" if (scalar @ARGV < 1);

$command = $ARGV[0];
if ($command eq 'search') {
	die "No tags provided.\n" if (scalar @ARGV < 2);

	@tag_criteria = split(',', $ARGV[1]);
	print "Searching...\n";

	# Read database and find tags.
	$results = 0;
	open(TAGDB, ".ptagdb") || die "Could not open ptag database. Does it even exist?\n";
	while ($line = <TAGDB>) {
		($file_name, $raw_tag_list) = $line =~ /(.+)\s*=\s*(.+)/;
		@file_tags = split(',', $raw_tag_list);

		for ($i = 0; $i < (scalar @tag_criteria); $i++) {
			$required_tag = $tag_criteria[$i];

			# See if the required tag is in the list.
			$has_required_tag = 0;
			for $tag (@file_tags) {
				$has_required_tag = 1 if ($tag eq $required_tag);
			}

			# If we didn't find it, then we must bail here.
			if ($has_required_tag == 0) {
				last;
			}

			# If this was the last tag, and we've reached here, then this is a query result.
			if ($i + 1 == (scalar @tag_criteria)) {
				print $file_name . "\n";
				$results++;
			}
		}
	}

	print "$results results.\n";
}

if ($command eq 'newdb') {
	@files = <*>;

	open(TAGDB, '>>', ".ptagdb") || die "Failed to open .ptagdb.\n";

	print "Will create a new database " . (scalar @files) . " files:\n";
	for $file (@files) {
		# We don't care to tag directories...
		next if (-d $file);
			
		$file_tags = "";

		while ($file_tags eq "") {
			print "Tags for " . $file . ":\n";
			$file_tags = <STDIN>;
			chomp $file_tags
		}
		print "\n";

		print TAGDB "$file = $file_tags\n";
	}

	print "Done!\n";
}

exit 0;
