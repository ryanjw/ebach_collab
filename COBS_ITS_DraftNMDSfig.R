#Elizabeth Bach
#COBS_ITS July & Aug 2012:  Drafting NMDS Figure to show community+env+taxa
#1 Aug 2014

library(gridExtra)

#Most of this code is copied from COBS_ITS_TargetTaxaNMDS.R
#It is cleaned-up, streamlined here to generate drafts of potential 3-panel figure
#Use merged_taxa, taxa.interest from COBS_ITS_TargetTaxaNMDS.R
#Use data.metadata2 from COBS_ITS_ComMetadataAnalysis.R

#NMDS plotting function, from R. Williams
ggplot.NMDS<-function(XX,ZZ,COLORS){
	library(ggplot2)
MDS1<-data.frame(scores(XX))$NMDS1
MDS2<-data.frame(scores(XX))$NMDS2
Treatment<-ZZ

NMDS<-data.frame(MDS1,MDS2,Treatment)

NMDS.mean=aggregate(NMDS[,1:2],list(group=Treatment),mean)

veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100) 
  {
    theta <- (0:npoints) * 2 * pi/npoints
    Circle <- cbind(cos(theta), sin(theta))
    t(center + scale * t(Circle %*% chol(cov)))
  }

  df_ell <- data.frame()
  for(g in levels(NMDS$Treatment)){
    df_ell <- rbind(df_ell, cbind(as.data.frame(with(NMDS[NMDS$Treatment==g,],
                    veganCovEllipse(cov.wt(cbind(MDS1,MDS2),wt=rep(1/length(MDS1),length(MDS1)))$cov,center=c(mean(MDS1),mean(MDS2)))))
                    ,group=g))
  }

X1<-ggplot(data = NMDS, aes(MDS1, MDS2)) + geom_point(aes(color = Treatment),size=3,alpha=0.75) +
    geom_path(data=df_ell, aes(x=MDS1, y=MDS2,colour=group), size=2, linetype=5)+theme_bw()+theme(aspect.ratio=1)+scale_color_manual(values=COLORS)+theme(axis.text.x=element_text(size=20),axis.text.y=element_text(size=20),axis.title.x=element_text(size=20),axis.title.y=element_text(size=20))+theme(legend.title=element_text(size=15),legend.text=element_text(size=15))
X1    
}

#Presence/Absence, both SoilFrac and Crop group out significantly:
mds.pa<-metaMDS(decostand(merged_taxa[,-c(1:11)],"pa" ),k=6,autotransform=FALSE, na.rm=TRUE)

#Taxa centroids, subsetting for P<0.05
IntVectors1<-envfit(mds.pa, taxa.interest[,6:15], na.rm=TRUE)
IntVectors1
vectors<-data.frame(IntVectors1$vectors[1:4])
vectors
names<-c("Limonomyces","Atheliales","UnkBasidio","Thanatephorus","Psathyrellaceae","Strophariaceae","Peziza","Bionectriaceae","Glomerales","Operculomyces")
IntVectors2<-data.frame(names, vectors)
IntVectors3<-(subset(IntVectors2, pvals<0.05))
IntVectors3

#Environmental vectors
envectors1<-envfit(mds.pa, data.metadata2[,7:15], na.rm=TRUE)
head(envectors1)
envectors1
vectors2<-data.frame(envectors1$vectors[1:4])
names<-c("water content","AP","BG","BX","CB","NAG","TC,TN","","C:N")
vectors3<-subset(data.frame(names,vectors2), pvals<0.05)
vectors3

PA.Crop<-ggplot.NMDS(mds.pa, (taxa.interest$Crop), rainbow(3))+geom_point(data=IntVectors3, aes(x=arrows.NMDS1,y=arrows.NMDS2),colour="darkgrey",size=3,inherit_aes=FALSE)+
geom_text(data=IntVectors3,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),vjust=1,hjust=0.5,size=4,fontface="bold")+geom_segment(data=vectors3, aes(x=0,xend=arrows.NMDS1,y=0,yend=arrows.NMDS2),arrow=arrow(length = unit(0.35, "cm")),colour="darkgrey",size=1,inherit_aes=FALSE)+
geom_text(data=vectors3,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),hjust=0.7,vjust=1.25,size=4,fontface="bold")+annotate("text", label="B)", x=-0.65, y=0.95, cex=8, font=2)+coord_cartesian(xlim=c(-0.8,1.25))+
theme(axis.line=element_line(size=2), aspect.ratio=1, panel.border=element_blank(),axis.ticks=element_line(size=2, colour="black"), legend.position=c(0.9, 0.95), legend.background=element_blank(), legend.text=element_text(size=12, face="bold"),legend.key=element_blank(),legend.title=element_blank(),panel.background=element_blank(), axis.text=element_text(size=16, face="bold", colour="black"), axis.title=element_text(size=18, face="bold", colour="black"))

PA.Crop

#altering NMDS plotting function, from R. Williams to include only LM, micro fraction centroids, which are only 2 statistically diff.
ggplot.NMDS2<-function(XX,ZZ,COLORS){
	library(ggplot2)
MDS1<-data.frame(scores(XX))$NMDS1
MDS2<-data.frame(scores(XX))$NMDS2
Treatment<-ZZ

NMDS<-data.frame(MDS1,MDS2,Treatment)

NMDS.mean=aggregate(NMDS[,1:2],list(group=Treatment),mean)

veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100) 
  {
    theta <- (0:npoints) * 2 * pi/npoints
    Circle <- cbind(cos(theta), sin(theta))
    t(center + scale * t(Circle %*% chol(cov)))
  }

  df_ella <- data.frame()
  for(g in levels(NMDS$Treatment)){
    df_ella <- rbind(df_ella, cbind(as.data.frame(with(NMDS[NMDS$Treatment=="LM",],
                    veganCovEllipse(cov.wt(cbind(MDS1,MDS2),wt=rep(1/length(MDS1),length(MDS1)))$cov,center=c(mean(MDS1),mean(MDS2)))))
                    ,group="LM"))
  }

veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100) 
  {
    theta <- (0:npoints) * 2 * pi/npoints
    Circle <- cbind(cos(theta), sin(theta))
    t(center + scale * t(Circle %*% chol(cov)))
  }

  df_ellb <- data.frame()
  for(g in levels(NMDS$Treatment)){
    df_ellb <- rbind(df_ellb, cbind(as.data.frame(with(NMDS[NMDS$Treatment=="Micro",],
                    veganCovEllipse(cov.wt(cbind(MDS1,MDS2),wt=rep(1/length(MDS1),length(MDS1)))$cov,center=c(mean(MDS1),mean(MDS2)))))
                    ,group="Micro"))
  }

X1<-ggplot(data = NMDS, aes(MDS1, MDS2)) + geom_point(aes(color = Treatment),size=3,alpha=0.75) +
    geom_path(data=df_ella, aes(x=MDS1, y=MDS2,colour=group), size=2, linetype=5)+geom_path(data=df_ellb, aes(x=MDS1, y=MDS2,colour=group), size=2, linetype=5)+theme_bw()+theme(aspect.ratio=1)+scale_color_manual(values=COLORS)+theme(axis.text.x=element_text(size=20),axis.text.y=element_text(size=20),axis.title.x=element_text(size=20),axis.title.y=element_text(size=20))+theme(legend.title=element_text(size=15),legend.text=element_text(size=15))
X1    
}

#Figure Draft, includes LM, Micro (stat. diff community (dispersion))+stat. sig environmental vectors + stat. sig. taxa centroids!

PA.SoilFrac<-ggplot.NMDS2(mds.pa, (taxa.interest$SoilFrac), rainbow(5))+geom_point(data=IntVectors3, aes(x=arrows.NMDS1,y=arrows.NMDS2),colour="darkgrey",size=3,inherit_aes=FALSE)+
geom_text(data=IntVectors3,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),vjust=1,hjust=0.5,size=4,fontface="bold")+geom_segment(data=vectors3, aes(x=0,xend=arrows.NMDS1,y=0,yend=arrows.NMDS2),arrow=arrow(length = unit(0.35, "cm")),colour="darkgrey",size=1,inherit_aes=FALSE)+
geom_text(data=vectors3,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),hjust=0.7,vjust=1.25,size=4,fontface="bold")+annotate("text", label="A)", x=-0.65, y=0.95, cex=8, font=2)+coord_cartesian(xlim=c(-0.8,1.25))+
theme(axis.line=element_line(size=2), aspect.ratio=1, panel.border=element_blank(),axis.ticks=element_line(size=2, colour="black"), legend.position=c(0.9, 0.9), legend.background=element_blank(), legend.text=element_text(size=12, face="bold"),legend.key=element_blank(),legend.title=element_blank(),panel.background=element_blank(), axis.text=element_text(size=16, face="bold", colour="black"), axis.title=element_text(size=18, face="bold", colour="black"))

PA.SoilFrac

#Abundance, Crop only is statistically affecting communities
#Note environmental vectos and taxa correlations are different with abundance compared with PA
mds.ab<-metaMDS(decostand(data.metadata2[,-c(1:19)],"total" ),k=6,autotransform=FALSE, na.rm=TRUE)

envectors2<-envfit(mds.ab, data.metadata2[,7:15], na.rm=TRUE)
envectors2
vectors.ab<-data.frame(envectors2$vectors[1:4])
vectors.ab
names<-c("moisture","AP","BG","BX","CB","NAG","","TC,TN,C:N","")
vectors.ab2<-subset(data.frame(names,vectors.ab), pvals<0.05)
vectors.ab2

IntVectors1ab<-envfit(mds.ab, taxa.interest[,6:15], na.rm=TRUE)
IntVectors1ab
vectors_ab<-data.frame(IntVectors1ab$vectors[1:4])
vectors_ab
names<-c("Limonomyces","Atheliales","UnkBasidio","Thanatephorus","Psathyrellaceae","Strophariaceae","Peziza","Bionectriaceae","Glomerales","Operculomyces")
IntVectors2ab<-subset(data.frame(names, vectors_ab), pvals<0.05)
IntVectors2ab

Abund.Crop<-ggplot.NMDS(mds.ab, (data.metadata2$Crop.x), rainbow(3))+geom_segment(data=vectors.ab2, aes(x=0,xend=arrows.NMDS1,y=0,yend=arrows.NMDS2),arrow=arrow(length = unit(0.35, "cm")),colour="darkgrey",size=1,inherit_aes=FALSE)+
geom_point(data=IntVectors2ab, aes(x=arrows.NMDS1,y=arrows.NMDS2),colour="darkgrey",size=3,inherit_aes=FALSE)+geom_text(data=IntVectors2ab,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),vjust=1,hjust=0.5,size=4,fontface="bold")+
geom_text(data=vectors.ab2,aes(x=arrows.NMDS1,y=arrows.NMDS2,label=names),hjust=0.1,vjust=-0.2,size=4,fontface="bold")+
annotate("text", label="C)", x=-1.2, y=0.95, cex=8, font=2)+coord_cartesian(xlim=c(-1.4,1.3))+
theme(axis.line=element_line(size=2), aspect.ratio=1, panel.border=element_blank(),axis.ticks=element_line(size=2, colour="black"), legend.position="none",panel.background=element_blank(), axis.text=element_text(size=16, face="bold", colour="black"), axis.title=element_text(size=18, face="bold", colour="black"))

Abund.Crop

#Draft Figure, 3 panels, horizontal
grid.arrange(PA.SoilFrac,PA.Crop,Abund.Crop, ncol=3)
#This needs a LOT of Aesthetic work!