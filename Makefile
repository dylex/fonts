fonts=$(foreach f,6x10 7x13 10x20,$(f) $(f)B $(f)O $(f)BO) 14x14
files=$(fonts:=.pcf.gz)
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
