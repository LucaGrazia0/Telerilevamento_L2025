#per esame sapere quali funzioni sono di quali pacchetti e chi sono e cosa servono
install.packages("viridis")
# r code for visualising satellite data 

library(terra)
library(imageRy)

im.list() #funzione per avere la listat totale di tutti i dati che abbiamo a disposizione 

# importing the data e b2 vuol dire banda 2
# for the all course we are going to use = instead <-
b2 = im.import("sentinel.dolomites.b2.tif")


#questi tre colori sono tre elementi di un vettore, usiamo quindi c per concatenare e mettiamo 100 al di fuori della funzione che rappresenta il numero di gamme di differenti colori 
cl <- colorRampPalette(c("black", "grey", "light grey")) (100)
plot(b2, col=cl)

# Exercise: import b3 and plot it with the previous palette
b3 <- im.import("sentinel.dolomites.b3.tif")
plot(b3, col=cl)

# Importing the red band
b4 <- im.import("sentinel.dolomites.b4.tif")
plot(b4, col=cl)

# Importing the NIR band
b8 <- im.import("sentinel.dolomites.b8.tif")
plot(b8, col=cl)

# Multiframe
par(mfrow=c(2,2))
plot(b2, col=cl)
plot(b3, col=cl)
plot(b4, col=cl)
plot(b8, col=cl)

# stack
sentstack <- c(b2, b3, b4, b8)
plot(sentstack, col=cl)

# Plotting one layer
dev.off()
plot(sentstack[[1]], col=cl)
plot(sentstack[[4]], col=cl)

# Multiframe with different color palette
par(mfrow=c(2,2))

clb <- colorRampPalette(c("dark blue", "blue", "light blue")) (100)
plot(b2, col=clb)

# Exercise: apply the same concept to the green band (b3)
clg <- colorRampPalette(c("dark green", "green", "light green")) (100)
plot(b3, col=clg)

# Plotting red band (b4)
clr <- colorRampPalette(c("dark red", "red", "pink")) (100)
plot(b4, col=clr)

# Plotting the NIR band (b8)
cln <- colorRampPalette(c("brown", "orange", "yellow")) (100)
plot(b8, col=cln)

# RGB plotting
# sentstack[[1]] blue
# sentstack[[2]] green
# sentstack[[3]] red
# sentstack[[4]] NIR
  
dev.off()
im.plotRGB(sentstack, r=3, g=2, b=1) # natural color image
im.plotRGB(sentstack, r=4, g=3, b=2) # false color image
im.plotRGB(sentstack, r=3, g=4, b=2) # false color image
im.plotRGB(sentstack, r=3, g=2, b=4) # false color image








#cose fatte ieri 4/03

# R code for visualizing satellite data

# install.packages("devtools")
library(devtools)
install_github("ducciorocchini/imageRy")

library(terra)
library(imageRy)

im.list()
 
# For the whole course we are going to make use of = instead of <-
# This is based on the following video:
# https://www.youtube.com/watch?v=OJMpKCKH1hM

b2 = im.import("sentinel.dolomites.b2.tif")
plot(b2, col=cl)

cl = colorRampPalette(c("black", "dark grey", "light grey"))(100)
plot(b2, col=cl)

cl = colorRampPalette(c("black", "dark grey", "light grey"))(3)
plot(b2, col=cl)
# tlumley@u.washington.edu, Thomas Lumley

# Exercise: make your own color ramp
# https://sites.stat.columbia.edu/tzheng/files/Rcolor.pdf


cl = colorRampPalette(c("royalblue3", "seagreen1", "red1"))(100)
plot(b2, col=cl)

#band 3 
b3=im.import("sentinel.dolomites.b3.tif")

#band 4
b4=im.import("sentinel.dolomites.b4.tif")

#band 8
b8=im.import("sentinel.dolomites.b8.tif")

#per fare un pannello multiframe, pria righe e poi colonne 
par(mfrow=c(1,4))


par(mfrow=c(1,4))
> b2 = im.import("sentinel.dolomites.b2.tif")
> b3=im.import("sentinel.dolomites.b3.tif")
> b4=im.import("sentinel.dolomites.b4.tif")
> b8=im.import("sentinel.dolomites.b8.tif")

#per cancellare
dev.off()


im.multiframe #è la stessa cosa che fare un par
im.multiframe(1,4)

#exercise: plot the plot using im.multiframe one on top pf the other 
im.multiframe (2,2)
> plot(b2)
> plot(b3)
> plot(b4)
plot(b4)
> plot(b8)
> cl=colorRampPalette(c("black","gray","light gray"))(100)
> plot(b2,col=cl)
> plot(b3,col=cl)
> plot(b4,col=cl)
> plot(b8,col=cl)

#impacchetto i dati e plotto
sent=c(b2,b3,b4,b8)
plot(sent, col=cl)
names(sent)= c("b2blu", "b3green", "b4red", "b8nir") cambio nomi

plot(sent, col=cl)

plot(sent$"b8nir")

 im.multiframe (2,2)
plot(sent [[4]])  #la doppia quadra serve per metterne solo uno se abbiamo una cosa unica 

#importing several bands altogether 
sentdol=im.import("sentinel.dolomites")

#per le correlazioni
pairs(sentdol)

#viridis
plot(sentdol, col=viridis(100)) #https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
