fonts=7x13
files=$(patsubst %,%.pcf.gz,$(foreach f,$(fonts),$(f) $(f)B $(f)O $(f)BO))
dir=/usr/share/fonts/dylex

all: $(files)

%.pcf: %.bdf
	bdftopcf -t -o $@ $<

%.pcf.gz: %.pcf
	gzip -f $<

install: all
	install $(files) $(dir)
	mkfontdir $(dir)

clean:
	rm -f *.pcf.gz *.pcf
