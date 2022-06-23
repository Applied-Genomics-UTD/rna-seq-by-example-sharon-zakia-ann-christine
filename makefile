DA=grinch.tar.gz
IDX=refs/grinch-genome.fa
his ?= hisat2 --rna-strandness R --max-intronlen 2500

do:
	wget -nc http://data.biostarhandbook.com/rnaseq/data/grinch.tar.gz\

up: do
	tar zxvf ${DA}


ids:up
	parallel echo {1}{2} ::: Cranky Wicked ::: 1 2 3 > ids
	hisat2-build ${IDX} ${IDX}

idxx:ids
	mkdir -p bam
	cat ids | parallel "${his}  -x ${IDX} -U reads/{}.fq  | samtools sort > bam/{}.bam"
	cat ids | parallel samtools index bam/{}.bam


count: idxx
	featureCounts -a refs/grinch-annotations_3.gtf -o counts.txt bam/C*.bam bam/W*.bam
	featureCounts -s 1 -a refs/grinch-annotations_3.gtf -o counts-anti.txt bam/C*.bam bam/W*.bam
	featureCounts -s 2 -a refs/grinch-annotations_3.gtf -o counts-sense.txt bam/C*.bam bam/W*.bam

gtf:count
	cat refs/grinch-annotations_2.gff | awk '$$3=="gene" { print $$0}' > genes.gff

tin:gtf
	bedtools coverage -S -a genes.gff -b bam/*.bam > coverage.txt
	cat coverage.txt | cut -f 9,13 | tr ";" "\t" | cut -f 1,3 | sort -k2,2rn > tin.txt







