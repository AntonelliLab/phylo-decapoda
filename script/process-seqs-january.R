## This script prepares the new decapoda sequences
## to be organised by marker (one file for all orthologous seqs
## for one marker. It does so by
## (1) downloading the sequences by accession,
## (2) performing all-vs-all BLAST (as in phylota)
## (3) do single-linkeage clustering
## (4) writing each cluster to file

require('rentrez')
source('blast.R')

## get fasta sequences from accessions
accessions <- unique(scan('../data/accessions.txt', what='text'))
res <- lapply(accessions, entrez_fetch, db='nucleotide', rettype='fasta')
res <- sapply(res, unlist)
seqstrs <- unlist(strsplit(res, "(?<=[^>])(?=\n>)", perl=T))
## clear defline
seqstrs <- gsub("^\n?>.*?\\n", "", seqstrs)
## clear newlines
seqstrs <- gsub("\n", "", seqstrs, fixed=TRUE)
names(seqstrs) <- accessions
save(seqstrs, file='seqstrs.rda')

make.blast.db(seqstrs)
blast.results <- blast.all.vs.all()
filtered.blast.results <- filter.blast.results(blast.results, seqstrs)
clusters <- cluster.blast.results(filtered.blast.results)
save(clusters, file='clusters.rda')

## get taxon names for seqs
seqinfo <- lapply(accessions, entrez_fetch, db='nucleotide', rettype='xml')
names(seqinfo) <- accessions
save(seqinfo, file='seqinfo.rda')
## taxon.names <- gsub(".*taxname\ \"(.+?)\".+", "\\1",seqinfo)
taxon.names <- unname(sapply(res, function(r) {
    r <- gsub("\\.", ". ", r)
    paste(strsplit(r, "\ ")[[1]][3:4], collapse=" ")
}))
taxon.names <- gsub(" ", "_", taxon.names)

## write clusters to file, with the species names as defline
for (i in 1:length(clusters)) {
    cl <- clusters[[i]]$gis
    curr.seqs <- seqstrs[cl]
    species <- sapply(names(curr.seqs), function(acc) {
        taxon.names[which(accessions==acc)]
    })
    ## names(curr.seqs) <- species
    cluster.name <- paste0("cluster-", i, ".fa")
    if (file.exists(cluster.name))
        unlink(cluster.name)
    for (j in 1:length(curr.seqs)) {
        cat(">", species[j], "\n", file=cluster.name, append=T, sep="")
        cat(curr.seqs[j], "\n", file=cluster.name, append=T)
    }
}
