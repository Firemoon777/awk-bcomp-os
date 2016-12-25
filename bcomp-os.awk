#!/bin/awk

BEGIN {
	isLaunched = 0;
	printf("Loading bcomp firmware...");
	print("asm\n\
		org 012\n\
		CLA\n\
		ADD 010\n\
		ROR\n\
		CLA\n\
		CMA\n\
		AND 011\n\
		begin:\n\
		BR 018") | "cat > bcomp-in";
	print("end") | "cat > bcomp-in";
	print("Done");

	printf("Uploading filesystem...");
	print("400 a 04c9 w 04d2 w") | "cat > bcomp-in";
	print("4c9 a 1007 w 0400 w 0002 w 2f00 w 0401 w 0000 w w w w 0006 w 0400 w 000c w 312e w 7478 w 7400 w 6162 w 6364 w 6566 w 6768 w 04dc w 696a w 6b6c w 0000 w w w") | "cat > bcomp-in";
	print("Done");

	printf("Setup scheduler...");
	context_count = 1;
	contexts[0] = "0|018|0000|0";
	split(contexts[0], current_context, "|");
	print("Done");
	print("018 a") | "cat > bcomp-in";
	print("c") | "cat > bcomp-in";
	print("bcomp-os loaded!");
	printf("# ");

} 

/^bcomp.{2}[0-9]/ {
	if (NR > 26) {
		print;
	}
}

/^shell/ {
	print $2 | "cat > bcomp-in";
}
