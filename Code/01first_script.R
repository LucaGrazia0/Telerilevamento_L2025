# First R coding from scratch

2+3

anna <- 2+3 #operazione di assegnazione ad un oggetto
chiara <- 4+6

anna + chiara 

Filippo   <- c(0.2, 0.4, 0.6, 0.8, 0.9)    #array che sarebbe il vettore e c vuol dire concatenate 
luca <- c(100, 80, 60, 50,10)

plot(luca, Filippo)  #correliamo i due vettori
plot(luca, Filippo, pch=19)
plot(luca, Filippo, pch=19, col="blue")
plot(luca, Filippo, pch=19, col="blue", cex=2)
plot(luca, Filippo, pch=19, col="blue", cex=2, xlab="rubbish", ylab="biomass")

#instealling packages 
#CRAN
install.packages("terra")
library(terra)

install.packages("devtools")
library(devtools)

install_github("ducciorocchini/imageRy")
library(imageRy)

im.list()
