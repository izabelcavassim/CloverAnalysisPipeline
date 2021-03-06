library(ggplot2)
library(grid)
library(gridExtra)
library(dplyr)

snp_density <- read.csv("snp_density.csv")
snp_density$SNP.density <- as.numeric(levels(snp_density$SNP.density))[snp_density$SNP.density]

convert_ranges <- function(x) {
    values <- as.numeric(unlist(strsplit(x, "-")))
    mean(values)
}

convert_ranges <- Vectorize(convert_ranges)

binsize <- 10000

snp_density$Location <- convert_ranges(levels(snp_density$Location)[snp_density$Location])
snp_density$Coverage <- snp_density$Sites/binsize

chromosomes <- sort(as.vector(unique(snp_density[,1])))

snp_density %>% filter(Coverage>0.05) -> snp_density

max_location <- max(snp_density$Location)

cat("Number of Sites:", sum(snp_density$Sites))
cat("Number of SNPs:", sum(snp_density$SNPs))

snp_density$Heterozygosity <- snp_density$SNP.density/(sum(1/1:399))

cat("Mean Heterozygosity:", mean(snp_density$Heterozygosity))

figures <- list()
for(chromosome in chromosomes[-1]){
    chrsub <- snp_density[snp_density$Chromosome==chromosome,]
    fig <- ggplot(chrsub, aes(x=Location, y=Heterozygosity)) + geom_bar(stat="identity") +
        theme_classic() + labs(title=chromosome) +
        theme(text = element_text(size=6)) +
        scale_y_continuous(limits=c(0, 0.05)) +
        scale_x_continuous(limits=c(0, max_location))
    figures[[chromosome]] <- fig
}

grid.arrange(grobs = figures, ncol=1)
