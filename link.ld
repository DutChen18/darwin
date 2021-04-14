OUTPUT_FORMAT(binary)

SECTIONS
{
	probe = 4;
	kill = 8;
	claim = 12;
	ldmod : {
		LONG(myno)
		LONG(SIZEOF(text))
		LONG(start - ADDR(text))
		LONG((SIZEOF(ldmod) - 16) / 4)
		*(prot)
	}
	text 0 : AT(SIZEOF(ldmod)) { *(text) }
}
