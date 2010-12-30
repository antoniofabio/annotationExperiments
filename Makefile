# keep gnu make from deleting intermediate files:
.SECONDARY:

%.rfa: %.gbff
	./gbff2fasta.R $< > $@

current/%.psl: current/refseq/hum.rfa %.fa
	./blat.R $^ $@

current/%.psl.RData: current/%.psl
	./psl2RData.R $< $@

current/%.gene_info.RData: current/%.psl.RData
	./bestgene.R $< $@
