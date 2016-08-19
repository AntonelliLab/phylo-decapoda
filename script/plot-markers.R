tab <- read.table('markers-backbone.tsv', header=T, sep='\t', row.names=1)
tab <- tab[-ncol(tab)]
tt <- apply(tab, 2, function(x)ifelse(x=='', 0, 1))
heatmap(tt, Rowv=NA, Colv=NA, col=c('white', 'black'), xlab="marker", ylab='species', margins=c(5,8), scale='row')

