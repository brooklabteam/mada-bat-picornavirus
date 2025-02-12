rm(list=ls())

library(ggplot2)
library(ggtree)
library(ape)
library(ggnewscale)
#install.packages('gdata')
library(gdata)
library(phylotools)
library(phytools)
library(phylobase)
library(cowplot)
library(ggtreeExtra)
library(viridis)

###packages loaded

##Set working directory
homewd= "/Users/gwenddolenkettenburg/Desktop/developer/mada-bat-picornavirus/"
setwd(paste0(homewd,"/raxml_trees/polymerase_region_summary_tree"))

#load the tree and root it
tree <-  read.tree("T1.raxml.supportFBP") 
rooted.tree <- root(tree, which(tree$tip.label == "NC_001547.1"))
#take a quick look in base R
plot(rooted.tree)

#Remove root from displaying, still calculates changes correctly without it
rooted.tree<-drop.tip(rooted.tree, "NC_001547.1")

#load tree data prepared from elsewhere
dat <- read.csv(("polymerase_summary_metadata.csv"), header = T, stringsAsFactors = F)

head(dat)

#check that your metadata matches your tree data
setdiff(rooted.tree$tip.label, dat$tip_label)
#check for duplicates
setdiff(dat$tip_label, rooted.tree$tip.label) #no duplicates
nrow(dat) #293
length(tree$tip.label) #293

#check subgroup names
unique(dat$Genus)

#pick order for the labels
dat$Genus <- factor(dat$Genus, levels = c("Cardiovirus","Hepatovirus","Kobuvirus","Kunsagivirus","Mischivirus",
                                          "Sapelovirus","Sapovirus","Shanbavirus","Teschovirus","Unclassified picornavirus",
                                          "Alphavirus"))   
#pick colors for virus genera
genuscolz<- c("Cardiovirus"="#0A9F9D","Hepatovirus"="#CEB175","Kobuvirus"="#E54E21","Kunsagivirus"="#6C8645","Mischivirus"="#C18748",
              "Sapelovirus"="#C52E19","Sapovirus"="#AF4E24","Shanbavirus"="#54D8B1","Teschovirus"="#b67c3b","Unclassified picornavirus"="#175149",
              "Alphavirus"="black")

#take a glance
p <- ggtree(rooted.tree) %<+% dat + geom_tippoint(aes(color=Genus)) +
  geom_tiplab(size=2) + geom_nodelab(size=1) +
  scale_color_manual(values=genuscolz) + 
  theme(legend.position = "none", legend.title = element_blank())
p #looks great

#now get new tip labels
dat$old_tip_label <- dat$tip_label
dat$new_label <- NA

#now check that you don't have NAs and blanks throughout the component parts of the name
#you also can edit the original csv file to replace these blanks if you can find the correct info

dat$Isolate  #some are blank, so convert those to NA
dat$Isolate[dat$Isolate==""] <- NA
dat$Accession #all good

dat$source
dat$source[dat$source==""] <- NA
dat$Country #some are blank, so convert those to NA
dat$Country[dat$Country==""] <- NA
dat$Collection_Date #these are messy, some are years and some are full dates. I just want years, will manually fix


#now, select the name based on what components are present for each sample

#all components with values:
dat$new_label[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)] <- paste(dat$Accession[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                             dat$Genus[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                             dat$Isolate[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                             dat$source[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                             dat$Country[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                             dat$Collection_Date[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)])

#and if there is an NA just drop it

#here NA in Isolate only:
dat$new_label[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)] <- paste(dat$Accession[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            dat$Genus[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            #dat$Isolate[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            dat$source[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                            dat$Country[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                            dat$Collection_Date[is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)])

#look at dat$new_label
dat$new_label #they all look great

#make sure to sort in order
colnames(dat)[colnames(dat)=="Accession"]="old_tip_label"
tree.dat <- data.frame(old_tip_label=rooted.tree$tip.label, num =1:length(rooted.tree$tip.label))
head(tree.dat)
head(dat)
tree.dat <- merge(tree.dat, dat, by = "old_tip_label", all.x = F, sort = F)

names(tree.dat)

tree.dat$tip_label <- tree.dat$new_label

#making separate datasets for heatmaps to go next to tree

contig<-data.frame(id=tree.dat$tip_label,Novel_contigs=tree.dat$num_genus_novel_contigs)
#rownames(contig) <- rooted.tree$tip.label

reads<-data.frame(id=tree.dat$tip_label,Novel_reads_log10=tree.dat$num_genus_novel_reads_log)
#rownames(reads) <- rooted.tree$tip.label

region<-data.frame(id=tree.dat$tip_label,Region=tree.dat$region)
#rownames(region) <- rooted.tree$tip.label

host<-data.frame(id=tree.dat$tip_label,Host_class=tree.dat$host_class)
#rownames(host) <- rooted.tree$tip.label

#make real tree.dat file for putting the tip points on the tree
tree.dat <- dplyr::select(tree.dat, tip_label, Isolate, Host, source, Country, Collection_Date, Genus, Seq_type, old_tip_label)

rooted.tree$tip.label <- tree.dat$tip_label

head(tree.dat)
#verify that the old labels match the new

cbind(tree.dat$old_tip_label, rooted.tree$tip.label)

#check out the labels
tree.dat$tip_label#all look good

#assign some stuff for shapes
tree.dat$Host[tree.dat$Host==0] <- "Non-bat host"
tree.dat$Host[tree.dat$Host==1] <- "Bat host"
tree.dat$Host <- as.factor(tree.dat$Host)
tree.dat$novel[tree.dat$novel==0] <- "Reference seq"
tree.dat$novel[tree.dat$novel==1] <- "Novel seq"
tree.dat$novel<-as.factor(tree.dat$novel)

shapez = c("Bat host" =  17, "Non-bat host" = 19, "Reference seq"=19,"Novel seq"=17)
colz2 = c('1' =  "yellow", '0' = "white")

circ<-ggtree(rooted.tree, layout="circular")

##Get the clade numbers so we can label
ggtree(rooted.tree) + geom_text(aes(label=node), hjust=-.3)

##base tree
p1 <- ggtree(rooted.tree, layout = "circular") %<+% tree.dat +
  geom_tippoint(aes(color=Genus, shape=novel), size=2,stroke=0,show.legend = T) +
  scale_color_manual(values=genuscolz)+
  scale_shape_manual(values=shapez) +
  guides(colour = "none")+
  theme(legend.position = c(0.3,0.5),
        legend.direction = "vertical",
        legend.text = element_text(size=10),
        legend.title = element_text(size=10),
        #legend.key = element_rect(fill = "transparent"),
        legend.key.size = unit(0.25, "cm")) +
  xlim(c(0,10)) 
p1

#rotate tree a bit
p1<-rotate_tree(p1, 90)
p1

#add clade labels
p1.1 <- p1 +
  geom_cladelabel(node = 290, label = "Kobuvirus",offset.text=0.1, fontsize=3, angle=315, hjust=0,align = TRUE, color="#E54E21") +
  geom_cladelabel(node = 288, label = "Kunsagivirus",offset.text=0.1, fontsize=3, angle=280,hjust=0.5,align = TRUE, color="#6C8645") +
  geom_cladelabel(node = 352, label = "Cardiovirus",offset.text=0.1, fontsize=3, angle=83,hjust=0.6,align = TRUE, color="#0A9F9D") +
  geom_cladelabel(node = 377, label = "Mischivirus",offset.text=0.1, fontsize=3,angle=65,hjust=0.4,align = TRUE, color="#C18748") +
  geom_cladelabel(node = 382, label = "Teschovirus",offset.text=0.1, fontsize=3,angle=51,hjust=0.7,align = TRUE, color="#b67c3b") +
  geom_cladelabel(node = 535, label = "Hepatovirus",offset.text=0.1, fontsize=3,angle=25,hjust=0.4,align = TRUE, color="#CEB175") +
  geom_cladelabel(node = 530, label = "Shanbavirus",offset.text=0.1, fontsize=3,angle=358,hjust=0.4,align = TRUE, color="#54D8B1") +
  geom_cladelabel(node = 503, label = "Sapelovirus",offset.text=0.1, fontsize=3,angle=340,hjust=0.4,align = TRUE, color="#C52E19") +
  geom_cladelabel(node = 501, label = "Bat picornavirus",offset.text=0.1,angle=320,hjust=0.5, fontsize=3,align = TRUE, color="#175149") +
  geom_cladelabel(node = 396, label = "Sapovirus",offset.text=0.1,angle=75, fontsize=3,align = TRUE,hjust=1, color="#AF4E24")
p1.1


##Add contig/read metadata
#attach various metadata to p1
p1.1 <- p1.1 %<+% contig

#pop contig data on top of the tree
p2<-p1.1+geom_fruit(#data=contig,
                  geom=geom_tile,
                  mapping=aes(fill=Novel_contigs),
                  width=0.3,
                  offset=0.15) + 
                scale_fill_viridis(option="G")
                  
p2

#attach various metadata to p2
p2<-p2 %<+% reads

p3<-p2+new_scale_fill()+
  geom_fruit(#data=reads,
  geom=geom_tile,
  mapping=aes(fill=Novel_reads_log10),
  width=0.3,
  offset=0.08
)  + scale_fill_viridis(option="B") 
  #guides(fill_continuous = guide_legend(order = 2),col = guide_legend(order = 1))
 # theme(legend.position = "left",
                 # legend.direction = "vertical",
                 # legend.text = element_text(size=11),
                 # legend.title = element_text(size=11),
                 # legend.key.size = unit(0.3, "cm"))
p3

