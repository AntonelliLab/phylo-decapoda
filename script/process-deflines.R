## This scripts takes fasta files as downloaded from genbank,
## parses their definition lines (e.g.)
## >gi|669056543|gb|KF828164.1| Acanthacaris caeca voucher ULLZ7574 18S ribosomal RNA gene, partial sequence
## and retreives their gi which is put as the single item in the defline.
## The new fasta is then written to file.

require('ape')
require('stringr')
require('rentrez')

data.dir <- "../data"
cleaned.data.dir <- "../data/cleaned/"

files <- list.files(path=data.dir, pattern="*.fasta", full.names=T)

for (f in files) {
    fasta <- read.FASTA(f)

    cat("Processing file ", f, "\n")

    ## extract gis
    gis <- gsub("gi\\|(\\d+).*", "\\1", names(fasta))

    ## get entrez entry
    entries <- lapply(gis, function(id) {
        entrez_fetch(db='nuccore', id=id, rettype='gb')
    })

    ## extract taxids and set as seq deflines
    taxids <- gsub(".*taxon:(\\d+).*", "\\1", entries)
    names(fasta) <- taxids

    ## write new file
    file.name <- paste0(substr(f, 1, nchar(f)-6), '-cleaned.fa')
    cat("Writing file ", file.name, "\n")
    write.dna(fasta, file=file.name, format='fasta')
}

## move files into 'cleaned' directory
dir.create(cleaned.data.dir)
system(paste0("mv ", data.dir, "/*cleaned.fa ", cleaned.data.dir))
