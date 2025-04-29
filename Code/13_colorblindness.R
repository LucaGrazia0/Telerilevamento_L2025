#in funzione della colorramppalette varia molto quello che vediamo 

#Packages
library(terra)
library(cblindplot)

setwd(~/Desktop/)
vinicunca=rast("vinicunca.jpg")
vinicunca=flip(vinicunca)
plot(vinicunca)


#simulating color blindness

im.multiframe(1,2)
im.plotRGB(vinicunca, r=1, g=2, b=3, title="standard")
im.plotRGB(vinicunca, r=2, g=1, b=3, title="protanopia")

rainbow=rast("rainbow.jpg")
plot(rainbow)

cblind.plot(rainbow, cvd="protanopia") #cvd=color vision deficency
cblind.plot(rainbow, cvd="deuteranopia")
cblind.plot(rainbow, cvd="tritanopia")
