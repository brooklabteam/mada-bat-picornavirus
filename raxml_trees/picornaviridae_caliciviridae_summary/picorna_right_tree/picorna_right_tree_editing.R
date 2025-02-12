rm(list=ls())

library(ggplot2)
library(ggtree)
library(ape)
library(ggnewscale)
#install.packages('gdata')
library(gdata)
library(phylotools)
library(phylobase)
library(cowplot)

###packages loaded

##Set working directory
homewd= "/Users/gwenddolenkettenburg/Desktop/developer/mada-bat-picornavirus/"
setwd(paste0(homewd,"/raxml_trees/picorna_right_tree"))

#load the tree and root it
tree <-  read.tree("T10.raxml.supportFBP") 
rooted.tree <- root(tree, which(tree$tip.label == "NC_001547.1"))
#take a quick look in base R
plot(rooted.tree)

#Remove root from displaying, still calculates changes correctly without it
rooted.tree<-drop.tip(rooted.tree, "NC_001547.1")

#load tree data prepared from elsewhere
dat <- read.csv(("picornaviridae_refseq_metadata_all_right.csv"), header = T, stringsAsFactors = F)
head(dat)

#check that your metadata matches your tree data
setdiff(rooted.tree$tip.label, dat$tip_label)
#check for duplicates
setdiff(dat$tip_label, rooted.tree$tip.label) #no duplicates
nrow(dat) #225
length(tree$tip.label) #225

#check subgroup names
unique(dat$Genus)

#pick order for the labels
dat$Genus <- factor(dat$Genus, levels = c("Aalivirus", "Ailurivirus",   "Ampivirus",   
                                          "Anativirus",   "Aphthovirus", "Aquamavirus", "Avihepatovirus",    
                                          "Avisivirus",  "Bopivirus",   "Cardiovirus",   "Cosavirus",
                                          "Crohivirus", "Cyprivirus", "Dicipivirus", "Enterovirus", 
                                          "Erbovirus", "Fipivirus", "Gallivirus", "Gruhelivirus",
                                          "Grusopivirus", "Harkavirus", "Hemipivirus", "Hepatovirus",
                                          "Hunnivirus", "Kobuvirus", "Kunsagivirus", "Limnipivirus",
                                          "Livupivirus", "Ludopivirus", "Malagasivirus", "Marsupivirus",
                                          "Megrivirus", "Mischivirus", "Mosavirus", "Orivirus","Oscivirus",
                                          "Parechovirus", "Pasivirus", "Passerivirus", "Pemapivirus",
                                          "Poecivirus", "Potamipivirus", "Rabovirus", "Rafivirus",
                                          "Rajidapivirus", "Rohelivirus", "Rosavirus", "Sakobuvirus",
                                          "Salivirus","Sapelovirus","Senecavirus","Shanbavirus",
                                          "Sicinivirus","Teschovirus","Torchivirus", "Tottorivirus",
                                          "Tremovirus","Tropivirus","Unclassified picornavirus",
                                          "Alphavirus"))   

dat$novel <- as.factor(dat$novel)

#take a glance
p <- ggtree(rooted.tree) %<+% dat + geom_tippoint(aes(color=Genus)) +
  geom_tiplab(size=2) + geom_nodelab(size=1) +
  #scale_color_manual(values=colz) + 
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

#and source only:
dat$new_label[!is.na(dat$Isolate) & !is.na(dat$Accession) &is.na(dat$source) &!is.na(dat$Country)] <- paste(dat$Accession[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            dat$Genus[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            dat$Isolate[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)], "|", 
                                                                                                            #dat$source[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                            dat$Country[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                            dat$Collection_Date[!is.na(dat$Isolate) & !is.na(dat$Accession) & is.na(dat$source) &!is.na(dat$Country)])


#and Country only
dat$new_label[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)] <- paste(dat$Accession[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)], "|", 
                                                                                                             dat$Genus[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)], "|", 
                                                                                                             dat$Isolate[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)], "|", 
                                                                                                             dat$source[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)], "|",
                                                                                                             #dat$Country[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) &!is.na(dat$Country)], "|",
                                                                                                             dat$Collection_Date[!is.na(dat$Isolate) & !is.na(dat$Accession) &!is.na(dat$source) & is.na(dat$Country)])


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
tree.dat <- dplyr::select(tree.dat, tip_label, Isolate, Host, source, Country, Collection_Date, Genus, Genus, novel, old_tip_label)

rooted.tree$tip.label <- tree.dat$tip_label

head(tree.dat)
#verify that the old labels match the new

cbind(tree.dat$old_tip_label, rooted.tree$tip.label)

#check out the labels
tree.dat$tip_label#all look good

tree.dat$Host[tree.dat$Host==0] <- "Non-bat host"
tree.dat$Host[tree.dat$Host==1] <- "Bat host"
tree.dat$Host <- as.factor(tree.dat$Host)
shapez = c("Bat host" =  17, "Non-bat host" = 19)
colz2 = c('1' =  "yellow", '0' = "white")


##uncollapsed tree
p1 <- ggtree(rooted.tree) %<+% tree.dat + geom_tippoint(aes(color=Genus, shape=Host), size=4,stroke=0,show.legend = T) +
  # scale_fill_manual(values=colz) +
  # scale_color_manual(values=colz)+
  scale_shape_manual(values=shapez) +
  new_scale_fill() +
  guides(colour = guide_legend(ncol = 3))+
  geom_tiplab(aes(fill = novel, show.legend=F), geom = "label", family="Helvetica", label.size = 0, label.padding = unit(0, "lines"), alpha=.4, size=4, nudge_x=0.05) +
  guides(fill="none")+#
  scale_fill_manual(values=colz2) +
  geom_treescale(fontsize=4, x=0,y=-3, linesize = .5) +
  guides(colour = guide_legend(ncol = 1))+
  theme(legend.position = "none", 
        legend.direction = "vertical",
        legend.text = element_text(size=12), 
        legend.key.size = unit(0.2, "cm")) +
  xlim(c(0,5))

p1

#add node shapes to represent bootstrap values
p0<-ggtree(rooted.tree)
p0.dat <- p0$data
p0.dat$Bootstrap <- NA
Bootstrap<-p0.dat$Bootstrap[(length(tree.dat$tip_label)+1):length(p0.dat$label)] <- as.numeric(p0.dat$label[(length(tree.dat$tip_label)+1):length(p0.dat$label)])#fill with label

#add bootstrap values to original plot
p1.1 <- p1  %<+% p0.dat + 
  ggnewscale::new_scale_fill() + 
  geom_nodepoint(aes(fill=Bootstrap, show.legend = T), shape=21, stroke=0)+
  scale_fill_continuous(low="yellow", high="red", limits=c(0,100))+
  #guides(fill_continuous = guide_legend(order = 2),col = guide_legend(order = 1))+
  theme(legend.position = "left",
        legend.direction = "vertical",
        legend.text = element_text(size=12),
        legend.title = element_text(size=12),
        legend.key.size = unit(0.3, "cm"))
p1.1


##Get the clade numbers so we can collapse unnnecesary clades
ggtree(rooted.tree) + geom_text(aes(label=node), hjust=-.3)


#collapsed tree

#add clade labels
p2 <- ggtree(rooted.tree) %<+% tree.dat + geom_tippoint(aes(color=Genus, shape=Host), size=4,stroke=0,show.legend = T) +
  # scale_fill_manual(values=colz) +
  # scale_color_manual(values=colz)+
  scale_shape_manual(values=shapez) +
  guides(colour = guide_legend(ncol = 3))+
  new_scale_fill() +
  geom_tiplab(aes(fill = novel, show.legend=F), geom = "label", Genus="Helvetica", label.size = 0, label.padding = unit(0, "lines"), alpha=.4, size=4, nudge_x=0.05) +
  guides(fill="none")+#
  scale_fill_manual(values=colz2) +
  geom_treescale(fontsize=4, x=0,y=-3, linesize = .5) +
  theme(legend.position = "none", 
        legend.direction = "vertical",
        legend.text = element_text(size=12), 
        legend.key.size = unit(0.3, "cm")) +
  xlim(c(0,5))+
  geom_cladelabel(node = 337, label = "Cardiovirus",offset=0.05, fontsize=4, color="black") +
  geom_cladelabel(node = 330, label = "Cosavirus", offset=0.05,fontsize=4, color="black") +
  geom_cladelabel(node = 325, label = "Cardiovirus", offset=0.05, fontsize=4, color="black") +
  geom_cladelabel(node = 320, label = "Apthovirus/Erbovirus/Bopivirus", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 311, label = "Salivirus", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 314, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 353, label = "Enterovirus", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 405, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 384, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 244, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 255, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 414, label = "Various picornaviridae", offset=0.05,fontsize=4, color="black")+
  geom_cladelabel(node = 435, label = "Fipivirus", offset=0.05,fontsize=4, color="black")
p2

#collapse the labeled clades
p3<-collapse(p2, 337)+geom_point2(aes(subset=(node==337)), size=4, shape=22, fill="white")
p4<-collapse(p3, 330)+geom_point2(aes(subset=(node==330)), size=4, shape=22, fill="white")
p5<-collapse(p4, 325)+geom_point2(aes(subset=(node==325)), size=4, shape=22, fill="white")
p6<-collapse(p5, 320)+geom_point2(aes(subset=(node==320)), size=4, shape=22, fill="white")
p7<-collapse(p6, 311)+geom_point2(aes(subset=(node==311)), size=4, shape=22, fill="white")
p8<-collapse(p7, 314)+geom_point2(aes(subset=(node==314)), size=4, shape=22, fill="white")
p9<-collapse(p8, 353)+geom_point2(aes(subset=(node==353)), size=4, shape=22, fill="white")
p10<-collapse(p9, 405)+geom_point2(aes(subset=(node==405)), size=4, shape=22, fill="white")
p11<-collapse(p10, 384)+geom_point2(aes(subset=(node==384)), size=4, shape=22, fill="white")
p12<-collapse(p11, 244)+geom_point2(aes(subset=(node==244)), size=4, shape=22, fill="white")
p13<-collapse(p12, 255)+geom_point2(aes(subset=(node==255)), size=4, shape=22, fill="white")
p14<-collapse(p13, 414)+geom_point2(aes(subset=(node==414)), size=4, shape=22, fill="white")
p15<-collapse(p14, 435)+geom_point2(aes(subset=(node==435)), size=4, shape=22, fill="white")
p15

##add bootstrap values to this tree
p15.dat <- p15$data
p15.dat$Bootstrap <- NA
Bootstrap<-p15.dat$Bootstrap[(length(tree.dat$tip_label)+1):length(p15.dat$label)] <- as.numeric(p15.dat$label[(length(tree.dat$tip_label)+1):length(p15.dat$label)])#fill with label

p16 <- p15  %<+% p15.dat + 
  ggnewscale::new_scale_fill() + 
  geom_nodepoint(aes(fill=Bootstrap, show.legend = T), shape=21, stroke=0)+
  scale_fill_continuous(low="yellow", high="red", limits=c(0,100))+
  #guides(fill_continuous = guide_legend(order = 2),col = guide_legend(order = 1))+
  theme(legend.position = "left",
        legend.direction = "vertical",
        legend.text = element_text(size=12),
        legend.title = element_text(size=12),
        legend.key.size = unit(0.3, "cm"))
p16

#17x13