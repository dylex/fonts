fonts=$(foreach f,6x10 7x13 10x20 14x14 12x20 14x26 20x40 28x28,$(f) $(f)B $(f)O $(f)BO)
files=$(fonts:=.pcf.gz)
dir=/usr/share/fonts/dylex

all: $(files)

%.pcf: %.bdf
	bdftopcf -t -o $@ $<

%.pcf.gz: %.pcf
	gzip -f $<

install: all
	install -m 644 $(files) $(dir)
	mkfontdir $(dir)

clean:
	rm -f *.pcf.gz *.pcf
