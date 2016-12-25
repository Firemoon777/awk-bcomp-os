#!/bin/awk

BEGIN {
	isLaunched = 0;
	ignore = 40;
	printf("Loading bcomp firmware...");
	print("asm\n\
		org 012\n\
		CLA\n\
		ADD 010\n\
		ROL\n\
		CLA\n\
		CMA\n\
		AND 011\n\
		begin:\n\
		BR 018\nNOP\nNOP\nNOP\nNOP\nCLF 3\nNOP\nHLT") | "cat > bcomp-in";
	print("end") | "cat > bcomp-in";
	print("Done");

	printf("Uploading filesystem...");
	print("400 a 04c9 w 04d2 w") | "cat > bcomp-in";
	print("4c9 a 1007 w 0400 w 0002 w 2f00 w 0401 w 0000 w w w w 0006 w 0400 w 000c w 312e w 7478 w 7400 w 6162 w 6364 w 6566 w 6768 w 04dc w 696a w 6b6c w 0000 w w w") | "cat > bcomp-in";
	print("Done");

	printf("Setup scheduler...");
	context = 0;
	contexts[0] = "018|0000|0";
	split(contexts[0], current_context, "|");
	time = 0;
	time_per_proc = 15;
	print("flag 3") | "cat > bcomp-in";
	print("Done");
	print("018 a") | "cat > bcomp-in";
	print("c") | "cat > bcomp-in";
	print("bcomp-os loaded!");
	printf("# ");

} 

/^bcomp.{2}[0-9]/ {
	if (NR > ignore || $3 == "F000") {
		killed = 0;
		if($3 == "F000") {
			for(i = context; i < length(contexts)-1; i++) {
				contexts[i] = contexts[i+1];
			}
			delete contexts[length(contexts)-1];
			killed = 1;
			#print("Contexts size: "length(contexts));
		}
		#print;

		time++;
		if(time >= time_per_proc || killed == 1) {
			time = 0;
			#print("Time to switch!");
  			ignore = NR + 10;
			if(killed == 0) {
				# save current contect
				contexts[context] = $4"|"$8"|"$9;
    				#print("Saved: "contexts[context]);
			}
			# switch to next context
			context = (context + 1) % length(contexts);
			split(contexts[context], current_context, "|");
			#print "context = "context;
			#print("Enabled: "contexts[context]);
			# Restore context
			print ("010 a "current_context[3]" w "current_context[2]" w c c c c c c "current_context[1]" a") | "cat > bcomp-in";
			#print("Switch completed");
		}
		print("c") | "cat > bcomp-in";
	}
}

/^shell/ {
	if($2 == "ls") {
		print("flag 3") | "cat > bcomp-in";
		contexts[length(contexts)] = "019|0000|0";
		next;
	}
	print $2 | "cat > bcomp-in";
}

function chr(c)
{
	return sprintf("%c", c + 0)
}

/^ВУ3/ {
	if($4 == 0) {
		printf chr($8);
		print("flag 3") | "cat > bcomp-in";
	}
}
