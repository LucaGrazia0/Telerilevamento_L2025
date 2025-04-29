# Exam project title: titolo

## data gathering 

data were gathered from the [Earth Observatory site](https://earthobservatory.nasa.gov/images/154116/floodwaters-surge-through-the-australian-outback)

```r
library(terra)
library(imageRy)
library(viridis) 
```

Setting the working directory and importing the data:

```r
setwd("~/Desktop/")
flood=rast(nasa.jpg)
plot(flood)
devo mettere l'immagine in png
dev.off()
```

the image is the following ![floodoutput](https://github.com/user-attachments/assets/75737c2c-de5f-471c-a891-24409b8a2112)


devo mettere l'immagine in png e posso anche trascinarla qui


## data analysis

```r
firesindex=flood[[1]]-flood[[2]]
plot(firesindex)
```

in order to export the index we can use the png()

```r
png("fireindex.png")
plot(fireindex)
dev.off
```

## index visualisation by viridis 

in order to vsualise the index with another viridiss...
```r
library(viridis)
plot(fireindex, col=inferno(100))
```
metto le immagini ovviamente per ogni step










