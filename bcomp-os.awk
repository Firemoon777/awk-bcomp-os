#!/bin/awk

BEGIN {
	print("asm\
		end")
}

/^bcomp/ {
	print;
}

/^shell/ {
	print $2 | "cat > bcomp-in";
}
